provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

locals {
  # replication.factor = 3: Confluent Cloud manages this replication factor; the provider does not expose it as a topic argument.
  orders_replication_factor = var.orders_replication_factor
}

resource "confluent_environment" "orders" {
  display_name = var.environment_name

  stream_governance {
    package = "ESSENTIALS"
  }
}

resource "confluent_kafka_cluster" "orders" {
  display_name = "orders-basic-cluster"
  availability = "SINGLE_ZONE"
  cloud        = var.cloud
  region       = var.region
  basic {}

  environment {
    id = confluent_environment.orders.id
  }
}

# The data source waits for Schema Registry to finish provisioning in this environment.
data "confluent_schema_registry_cluster" "essentials" {
  environment {
    id = confluent_environment.orders.id
  }

  depends_on = [confluent_kafka_cluster.orders]
}

resource "confluent_kafka_topic" "orders_v1" {
  kafka_cluster {
    id = confluent_kafka_cluster.orders.id
  }

  topic_name = "orders.v1"

  partitions_count = var.orders_partitions # 6 partitions provide parallelism and are explicitly configured.

  rest_endpoint = confluent_kafka_cluster.orders.rest_endpoint
  credentials {
    key    = var.confluent_kafka_admin_api_key
    secret = var.confluent_kafka_admin_api_secret
  }

  config = {
    # 2 replicas must acknowledge writes before they are committed, balancing durability and availability.
    "min.insync.replicas" = tostring(var.orders_min_isr)
  }
}

resource "confluent_service_account" "orders_producer" {
  display_name = "orders-v1-producer"
  description  = "Least-privilege service account allowed to produce only to orders.v1"
}

resource "confluent_api_key" "orders_producer_kafka" {
  display_name = "orders-v1-producer-kafka-key"
  description  = "Kafka API key owned by the orders.v1 producer service account"

  owner {
    id          = confluent_service_account.orders_producer.id
    api_version = confluent_service_account.orders_producer.api_version
    kind        = confluent_service_account.orders_producer.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.orders.id
    api_version = confluent_kafka_cluster.orders.api_version
    kind        = confluent_kafka_cluster.orders.kind

    environment {
      id = confluent_environment.orders.id
    }
  }
}

resource "confluent_kafka_acl" "orders_producer_write" {
  kafka_cluster {
    id = confluent_kafka_cluster.orders.id
  }

  resource_type = "TOPIC"
  resource_name = confluent_kafka_topic.orders_v1.topic_name
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.orders_producer.id}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"

  rest_endpoint = confluent_kafka_cluster.orders.rest_endpoint
  credentials {
    key    = var.confluent_kafka_admin_api_key
    secret = var.confluent_kafka_admin_api_secret
  }
}
