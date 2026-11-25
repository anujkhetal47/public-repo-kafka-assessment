# Confluent Cloud Kafka Assessment

This repository contains Terraform for:

- a Confluent Cloud environment with Schema Registry Essentials;
- a single-zone Basic Kafka cluster;
- an `orders.v1` topic with 6 partitions, a three-replica target, and `min.insync.replicas = 2`;
- one `orders-v1-producer` service account with WRITE permission only for `orders.v1`.

## Setup

```powershell
cd terraform
Copy-Item terraform.tfvars.example terraform.tfvars
# Add Cloud API credentials and a Kafka cluster admin API key/secret.
terraform init
terraform plan
terraform apply
```

Credential variables can also be supplied with `CONFLUENT_CLOUD_API_KEY`, `CONFLUENT_CLOUD_API_SECRET`, `TF_VAR_confluent_kafka_admin_api_key`, and `TF_VAR_confluent_kafka_admin_api_secret`.

## Security

`terraform.tfvars`, Terraform state, provider cache directories, and crash logs are gitignored. Never commit credentials or generated API secrets.
