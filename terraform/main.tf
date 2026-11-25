provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

resource "confluent_environment" "onboarded" {
  for_each = var.environments

  display_name = each.value.name

  stream_governance {
    package = "ESSENTIALS"
  }
}

resource "confluent_kafka_cluster" "onboarded" {
  for_each = var.kafka_clusters

  display_name = each.value.name
  availability = each.value.availability
  cloud        = each.value.cloud
  region       = each.value.region
  basic {}

  # replication.factor = 3: Confluent Cloud Basic clusters use three replicas.
  environment {
    id = confluent_environment.onboarded[each.value.environment_key].id
  }
}

# Load the automatically provisioned Essentials Schema Registry cluster per environment.
data "confluent_schema_registry_cluster" "essentials" {
  for_each = var.environments

  environment {
    id = confluent_environment.onboarded[each.key].id
  }

  depends_on = [confluent_kafka_cluster.onboarded]
}

resource "confluent_service_account" "topic_manager" {
  for_each = var.kafka_clusters

  display_name = "${each.value.name}-topic-manager"
  description  = "Creates and manages topics in ${each.value.name}"
}

resource "confluent_role_binding" "topic_manager_cluster_admin" {
  for_each = var.kafka_clusters

  principal   = "User:${confluent_service_account.topic_manager[each.key].id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.onboarded[each.key].rbac_crn
}

resource "confluent_api_key" "topic_manager_kafka" {
  for_each = var.kafka_clusters

  display_name = "${each.value.name}-topic-manager-kafka-key"
  description  = "Kafka API key for managing topics in ${each.value.name}"

  owner {
    id          = confluent_service_account.topic_manager[each.key].id
    api_version = confluent_service_account.topic_manager[each.key].api_version
    kind        = confluent_service_account.topic_manager[each.key].kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.onboarded[each.key].id
    api_version = confluent_kafka_cluster.onboarded[each.key].api_version
    kind        = confluent_kafka_cluster.onboarded[each.key].kind

    environment {
      id = confluent_environment.onboarded[each.value.environment_key].id
    }
  }

  depends_on = [confluent_role_binding.topic_manager_cluster_admin]
}

resource "confluent_service_account" "topic_producer" {
  for_each = var.topic_producers

  display_name = each.value.name
  description  = "Least-privilege producer for ${join(", ", each.value.topic_keys)}"
}

resource "confluent_api_key" "topic_producer_kafka" {
  for_each = var.topic_producers

  display_name = "${each.value.name}-kafka-key"
  description  = "Kafka API key owned by ${each.value.name}"

  owner {
    id          = confluent_service_account.topic_producer[each.key].id
    api_version = confluent_service_account.topic_producer[each.key].api_version
    kind        = confluent_service_account.topic_producer[each.key].kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.onboarded[each.value.cluster_key].id
    api_version = confluent_kafka_cluster.onboarded[each.value.cluster_key].api_version
    kind        = confluent_kafka_cluster.onboarded[each.value.cluster_key].kind

    environment {
      id = confluent_environment.onboarded[var.kafka_clusters[each.value.cluster_key].environment_key].id
    }
  }
}

resource "confluent_kafka_acl" "topic_producer_write" {
  for_each = {
    for request in flatten([
      for producer_key, producer in var.topic_producers : [
        for topic_key in producer.topic_keys : {
          key          = "${producer_key}-${topic_key}"
          producer_key = producer_key
          topic_key    = topic_key
        }
      ]
    ]) : request.key => request
  }

  kafka_cluster {
    id = confluent_kafka_cluster.onboarded[var.topic_producers[each.value.producer_key].cluster_key].id
  }

  resource_type = "TOPIC"
  resource_name = confluent_kafka_topic.onboarded[each.value.topic_key].topic_name
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.topic_producer[each.value.producer_key].id}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"

  rest_endpoint = confluent_kafka_cluster.onboarded[var.topic_producers[each.value.producer_key].cluster_key].rest_endpoint
  credentials {
    key    = confluent_api_key.topic_manager_kafka[var.topic_producers[each.value.producer_key].cluster_key].id
    secret = confluent_api_key.topic_manager_kafka[var.topic_producers[each.value.producer_key].cluster_key].secret
  }
}

moved {
  from = confluent_environment.orders
  to   = confluent_environment.onboarded["orders"]
}

moved {
  from = confluent_kafka_cluster.orders
  to   = confluent_kafka_cluster.onboarded["orders"]
}

moved {
  from = confluent_service_account.topic_manager
  to   = confluent_service_account.topic_manager["orders"]
}

moved {
  from = confluent_role_binding.topic_manager_cluster_admin
  to   = confluent_role_binding.topic_manager_cluster_admin["orders"]
}

moved {
  from = confluent_api_key.topic_manager_kafka
  to   = confluent_api_key.topic_manager_kafka["orders"]
}

moved {
  from = confluent_service_account.orders_producer
  to   = confluent_service_account.topic_producer["orders_producer"]
}

moved {
  from = confluent_api_key.orders_producer_kafka
  to   = confluent_api_key.topic_producer_kafka["orders_producer"]
}

moved {
  from = confluent_kafka_acl.orders_producer_write
  to   = confluent_kafka_acl.topic_producer_write["orders_producer-orders_v1"]
}
