output "bootstrap_endpoints" {
  description = "Confluent Cloud Kafka bootstrap endpoints keyed by cluster identifier"
  value = {
    for key, cluster in confluent_kafka_cluster.onboarded : key => cluster.bootstrap_endpoint
  }
}

output "bootstrap_endpoint" {
  description = "Backward-compatible bootstrap endpoint for the orders cluster"
  value       = confluent_kafka_cluster.onboarded["orders"].bootstrap_endpoint
}

output "environment_ids" {
  description = "Confluent Cloud environment IDs keyed by environment identifier"
  value = {
    for key, environment in confluent_environment.onboarded : key => environment.id
  }
}

output "environment_id" {
  description = "Backward-compatible environment ID for the orders environment"
  value       = confluent_environment.onboarded["orders"].id
}

output "schema_registry_endpoints" {
  description = "Essentials Schema Registry REST endpoints keyed by environment identifier"
  value = {
    for key, schema_registry in data.confluent_schema_registry_cluster.essentials : key => schema_registry.rest_endpoint
  }
}

output "schema_registry_endpoint" {
  description = "Backward-compatible Schema Registry endpoint for the orders environment"
  value       = data.confluent_schema_registry_cluster.essentials["orders"].rest_endpoint
}

output "topic_producer_api_keys" {
  description = "Producer Kafka API key IDs keyed by producer identifier"
  value = {
    for key, api_key in confluent_api_key.topic_producer_kafka : key => api_key.id
  }
}

output "orders_producer_api_key" {
  description = "Backward-compatible API key ID for the orders producer"
  value       = confluent_api_key.topic_producer_kafka["orders_producer"].id
}

output "topic_producer_api_secrets" {
  description = "Producer Kafka API secrets keyed by producer identifier"
  value = {
    for key, api_key in confluent_api_key.topic_producer_kafka : key => api_key.secret
  }
  sensitive = true
}

output "orders_producer_api_secret" {
  description = "Backward-compatible API secret for the orders producer"
  value       = confluent_api_key.topic_producer_kafka["orders_producer"].secret
  sensitive   = true
}
