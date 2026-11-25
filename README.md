# Confluent Cloud Kafka Assessment

This repository provisions:

- a Confluent Cloud environment with Schema Registry Essentials;
- a single-zone Basic Kafka cluster;
- the `orders.v1` topic with 6 partitions and `min.insync.replicas = 2`;
- one producer service account with `WRITE` permission only for `orders.v1`;
- the Kafka bootstrap endpoint as a Terraform output.

The Basic cluster uses Confluent Cloud's replication factor of 3.

## Setup

```powershell
cd terraform
Copy-Item terraform.tfvars.example terraform.tfvars
# Add the Confluent Cloud API credentials.
terraform init
terraform validate
terraform plan
terraform apply
```

Credentials can also be supplied through `CONFLUENT_CLOUD_API_KEY` and `CONFLUENT_CLOUD_API_SECRET`.

## Consumer lag report

Install dependencies and run the lag report without placing credentials in command history:

```powershell
python -m pip install -r requirements.txt
$env:KAFKA_BOOTSTRAP_SERVERS = "pkc-example.us-east-2.aws.confluent.cloud:9092"
$env:KAFKA_API_KEY = "your-api-key"
$env:KAFKA_API_SECRET = "your-api-secret"
python scripts/lag_report.py --group your-consumer-group
```

The script prints a JSON array with topic, partition, committed offset, log-end offset, and lag. Exit code `2` means the consumer group does not exist; exit code `1` means the broker remained unreachable after three attempts.

## Ansible rolling broker change

The `ansible/` directory contains a small role that safely changes `num.replica.fetchers` on Kafka brokers:

```powershell
cd ansible
ansible-playbook -i inventory.ini site.yml --check --diff
```

The play uses `serial: 1`, checks under-replicated partitions before and after each restart, and restarts only when the configuration changes.

## Assessment write-ups

- Detailed answers for Sections 1.1–1.5: [`answers.md`](answers.md)
- Deferred scope and AI usage: [`NOTES.md`](NOTES.md)

## Security

Real `*.tfvars` files and Terraform state are gitignored. Do not commit credentials or generated API secrets.

## Submission checklist

- [x] Section 1: architecture and operational answers in [`answers.md`](answers.md)
- [x] Section 2a: Terraform in [`terraform/`](terraform)
- [x] Section 2b: serialized Ansible role in [`ansible/`](ansible)
- [x] Section 3: Python lag report in [`scripts/lag_report.py`](scripts/lag_report.py)
- [x] Deferred scope and AI usage in [`NOTES.md`](NOTES.md)

## Local validation

- Terraform: `terraform validate` passes; live plan and no-change follow-up plan were tested.
- Python: syntax, unreachable-broker, missing-group, and live lag JSON behavior were tested locally.
- Ansible: all YAML files parsed successfully; native broker execution requires target inventory and host access.
