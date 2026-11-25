#!/usr/bin/env python3
import argparse
import json
import os
import sys
import time

from confluent_kafka import Consumer, ConsumerGroupTopicPartitions, TopicPartition
from confluent_kafka.admin import AdminClient
from confluent_kafka import KafkaException


def parse_args():
    parser = argparse.ArgumentParser(description="Report consumer-group lag as JSON")
    parser.add_argument("--bootstrap", default=os.getenv("KAFKA_BOOTSTRAP_SERVERS"))
    parser.add_argument("--api-key", default=os.getenv("KAFKA_API_KEY"))
    parser.add_argument("--api-secret", default=os.getenv("KAFKA_API_SECRET"))
    parser.add_argument("--group", required=True)
    args = parser.parse_args()
    missing = [name for name, value in (
        ("bootstrap", args.bootstrap), ("api-key", args.api_key),
        ("api-secret", args.api_secret)) if not value]
    if missing:
        parser.error("missing required inputs: " + ", ".join(missing))
    return args


def retry(operation):
    delay = 1
    for attempt in range(3):
        try:
            return operation()
        except (KafkaException, TimeoutError, OSError) as error:
            if attempt == 2:
                raise
            time.sleep(delay)
            delay *= 2


def group_exists(admin, group):
    result = admin.list_consumer_groups(request_timeout=10).result(timeout=10)
    return any(getattr(item, "group_id", None) == group for item in result.valid)


def get_offsets(admin, group):
    request = ConsumerGroupTopicPartitions(group)
    futures = admin.list_consumer_group_offsets([request], request_timeout=10)
    response = futures[group].result(timeout=10)
    return getattr(response, "topic_partitions", [])


def build_report(admin, args, config):
    offsets = get_offsets(admin, args.group)
    consumer = Consumer({**config, "group.id": args.group,
                         "enable.auto.commit": False})
    report = []
    try:
        for item in offsets:
            if item.error:
                continue
            low, high = consumer.get_watermark_offsets(
                TopicPartition(item.topic, item.partition), timeout=10)
            current = item.offset if item.offset >= 0 else None
            lag = max(high - current, 0) if current is not None else high
            report.append({"topic": item.topic, "partition": item.partition,
                           "current_offset": current,
                           "log_end_offset": high, "lag": lag})
    finally:
        consumer.close()
    return report


def main():
    args = parse_args()
    config = {
        "bootstrap.servers": args.bootstrap,
        "security.protocol": "SASL_SSL",
        "sasl.mechanism": "PLAIN",
        "sasl.username": args.api_key,
        "sasl.password": args.api_secret,
        "socket.timeout.ms": "10000",
    }
    admin = AdminClient(config)

    try:
        exists = retry(lambda: group_exists(admin, args.group))
    except Exception as error:
        print(f"Broker unreachable: {error}", file=sys.stderr)
        return 1

    if not exists:
        print(f"Consumer group '{args.group}' does not exist", file=sys.stderr)
        return 2

    try:
        report = retry(lambda: build_report(admin, args, config))
    except Exception as error:
        print(f"Broker unreachable: {error}", file=sys.stderr)
        return 1

    print(json.dumps(sorted(report, key=lambda row: (row["topic"], row["partition"]))))
    return 0


if __name__ == "__main__":
    sys.exit(main())
