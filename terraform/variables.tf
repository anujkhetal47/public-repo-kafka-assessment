variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API key used for control-plane resources"
  type        = string
  sensitive   = true
}

variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API secret used for control-plane resources"
  type        = string
  sensitive   = true
}

variable "cloud" {
  description = "Cloud provider for the Kafka cluster"
  type        = string
  default     = "AWS"
}

variable "region" {
  description = "Region for the Kafka and Schema Registry resources"
  type        = string
  default     = "us-east-2"
}

variable "environment_name" {
  description = "Confluent Cloud environment display name"
  type        = string
  default     = "banking-orders-assessment"
}
