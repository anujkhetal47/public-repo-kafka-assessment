provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
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

  # replication.factor = 3: Confluent Cloud Basic clusters use three replicas.
  environment {
    id = confluent_environment.orders.id
  }
}

# Load the automatically provisioned Essentials Schema Registry cluster.
data "confluent_schema_registry_cluster" "essentials" {
  environment {
    id = confluent_environment.orders.id
  }

  depends_on = [confluent_kafka_cluster.orders]
}

resource "confluent_service_account" "topic_manager" {
  display_name = "orders-v1-topic-manager"
  description  = "Creates and manages the orders.v1 topic and ACL"
}

resource "confluent_role_binding" "topic_manager_cluster_admin" {
  principal   = "User:${confluent_service_account.topic_manager.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.orders.rbac_crn
}

resource "confluent_api_key" "topic_manager_kafka" {
  display_name = "orders-v1-topic-manager-kafka-key"
  description  = "Kafka API key for managing orders.v1"

  owner {
    id          = confluent_service_account.topic_manager.id
    api_version = confluent_service_account.topic_manager.api_version
    kind        = confluent_service_account.topic_manager.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.orders.id
    api_version = confluent_kafka_cluster.orders.api_version
    kind        = confluent_kafka_cluster.orders.kind

    environment {
      id = confluent_environment.orders.id
    }
  }

  depends_on = [confluent_role_binding.topic_manager_cluster_admin]
}

resource "confluent_service_account" "orders_producer" {
  display_name = "orders-v1-producer"
  description  = "Least-privilege service account allowed to produce only to orders.v1"
}

resource "confluent_api_key" "orders_producer_kafka" {
  display_name = "orders-v1-producer-kafka-key"
  description  = "Kafka API key owned by the orders.v1 producer"

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
    key    = confluent_api_key.topic_manager_kafka.id
    secret = confluent_api_key.topic_manager_kafka.secret
  }
}
