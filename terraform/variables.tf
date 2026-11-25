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

variable "orders_partitions" {
  description = "Number of partitions for orders.v1"
  type        = number
  default     = 6

  validation {
    condition     = var.orders_partitions >= 1
    error_message = "orders_partitions must be at least 1."
  }
}

variable "orders_replication_factor" {
  description = "Desired replication factor for orders.v1"
  type        = number
  default     = 3

  validation {
    condition     = var.orders_replication_factor >= 1
    error_message = "orders_replication_factor must be at least 1."
  }
}

variable "orders_min_isr" {
  description = "Minimum in-sync replicas for orders.v1"
  type        = number
  default     = 2

  validation {
    condition     = var.orders_min_isr >= 1
    error_message = "orders_min_isr must be at least 1."
  }
}

variable "confluent_kafka_admin_api_key" {
  description = "Kafka cluster admin API key used to create the topic and ACL"
  type        = string
  sensitive   = true
}

variable "confluent_kafka_admin_api_secret" {
  description = "Kafka cluster admin API secret used to create the topic and ACL"
  type        = string
  sensitive   = true
}
