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
  description = "Region for the Kafka cluster and Schema Registry"
  type        = string
  default     = "us-east-2"
}

variable "environment_name" {
  description = "Confluent Cloud environment display name"
  type        = string
  default     = "banking-orders-assessment"
}

variable "replication_factor" {
  description = "Replication factor for a Confluent Cloud Basic cluster topic"
  type        = number
  default     = 3

  validation {
    condition     = var.replication_factor == 3
    error_message = "Confluent Cloud Basic clusters use a replication factor of 3."
  }
}
