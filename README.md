# Confluent Cloud Kafka Assessment

This repository contains map-driven Terraform for:

- Confluent Cloud environments with Schema Registry Essentials;
- one or more single-zone Basic Kafka clusters;
- self-service topic onboarding through `kafka_topics`;
- least-privilege producer accounts and literal topic WRITE ACLs;
- pinned Confluent provider and environment/credential separation.

The default configuration creates `orders.v1` with 6 partitions, replication factor 3, and `min.insync.replicas = 2`.

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

## Topic self-service onboarding

Copy the example request file as needed:

```powershell
Copy-Item topic-onboarding.tfvars.example topics.local.tfvars
terraform plan -var-file=topics.local.tfvars
terraform apply -var-file=topics.local.tfvars
```

Clients add entries to `kafka_topics` and `topic_producers`. Each topic request declares:

- a stable topic key;
- a topic name;
- the target cluster key;
- partitions;
- replication factor;
- minimum in-sync replicas.

Each producer request declares a service-account name, target cluster, and a list of exact topic keys. Terraform creates the API key and a separate literal `WRITE` ACL for every producer-topic pair.

## Security

`*.tfvars` files, Terraform state, provider cache directories, and crash logs are gitignored. The example files are safe to commit. Never commit credentials or generated API secrets.
