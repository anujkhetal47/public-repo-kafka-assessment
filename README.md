# Confluent Cloud Kafka Assessment

This repository contains Terraform for:

- a Confluent Cloud environment with Schema Registry Essentials;
- a single-zone Basic Kafka cluster;
- an `orders.v1` topic with 6 partitions, replication factor 3, and `min.insync.replicas = 2`;
- a Terraform-managed topic manager for cluster operations;
- one `orders-v1-producer` service account with WRITE permission only for `orders.v1`.

## Setup

```powershell
cd terraform
Copy-Item terraform.tfvars.example terraform.tfvars
# Add only the Confluent Cloud API credentials.
terraform init
terraform validate
terraform plan
terraform apply
```

Credential variables can also be supplied through `CONFLUENT_CLOUD_API_KEY` and `CONFLUENT_CLOUD_API_SECRET`.

## Security

`terraform.tfvars`, Terraform state, provider cache directories, and crash logs are gitignored. Never commit credentials or generated API secrets.
