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

## Security

Real `*.tfvars` files and Terraform state are gitignored. Do not commit credentials or generated API secrets.
