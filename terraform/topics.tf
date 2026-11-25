# Preserve the existing live topic while moving it back to the simple resource address.
moved {
  from = confluent_kafka_topic.onboarded["orders_v1"]
  to   = confluent_kafka_topic.orders_v1
}

resource "confluent_kafka_topic" "orders_v1" {
  kafka_cluster {
    id = confluent_kafka_cluster.orders.id
  }

  topic_name = "orders.v1"

  # Six partitions provide parallelism across independent order workloads.
  partitions_count = 6

  rest_endpoint = confluent_kafka_cluster.orders.rest_endpoint
  credentials {
    key    = confluent_api_key.topic_manager_kafka.id
    secret = confluent_api_key.topic_manager_kafka.secret
  }

  config = {
    # Two replicas must acknowledge writes for durable, available writes.
    "min.insync.replicas" = "2"
  }

  depends_on = [confluent_api_key.topic_manager_kafka]
}
