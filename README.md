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

## Security

Real `*.tfvars` files and Terraform state are gitignored. Do not commit credentials or generated API secrets.
