output "bootstrap_endpoint" {
  description = "Confluent Cloud Kafka bootstrap endpoint"
  value       = confluent_kafka_cluster.orders.bootstrap_endpoint
}

output "environment_id" {
  description = "Confluent Cloud environment ID"
  value       = confluent_environment.orders.id
}

output "schema_registry_endpoint" {
  description = "Essentials Schema Registry REST endpoint"
  value       = data.confluent_schema_registry_cluster.essentials.rest_endpoint
}

output "orders_producer_api_key" {
  description = "Producer service account Kafka API key ID"
  value       = confluent_api_key.orders_producer_kafka.id
}

output "orders_producer_api_secret" {
  description = "Producer service account Kafka API secret"
  value       = confluent_api_key.orders_producer_kafka.secret
  sensitive   = true
}
