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
  description = "Default cloud provider for Kafka clusters"
  type        = string
  default     = "AWS"
}

variable "region" {
  description = "Default region for Kafka clusters"
  type        = string
  default     = "us-east-2"
}

variable "environment_name" {
  description = "Legacy default environment name retained for compatibility"
  type        = string
  default     = "banking-orders-assessment"
}

variable "environments" {
  description = "Confluent environments available for cluster onboarding"
  type = map(object({
    name = string
  }))

  default = {
    orders = {
      name = "banking-orders-assessment"
    }
  }
}

variable "kafka_clusters" {
  description = "Kafka clusters keyed by a stable onboarding identifier"
  type = map(object({
    name            = string
    environment_key = string
    availability    = string
    cloud           = string
    region          = string
  }))

  default = {
    orders = {
      name            = "orders-basic-cluster"
      environment_key = "orders"
      availability    = "SINGLE_ZONE"
      cloud           = "AWS"
      region          = "us-east-2"
    }
  }

  validation {
    condition = alltrue([
      for cluster in values(var.kafka_clusters) : cluster.availability == "SINGLE_ZONE"
    ])
    error_message = "This assessment configuration uses single-zone Basic clusters."
  }

  validation {
    condition = alltrue([
      for cluster in values(var.kafka_clusters) : contains(["AWS", "AZURE", "GCP"], cluster.cloud)
    ])
    error_message = "Cloud must be AWS, AZURE, or GCP."
  }
}

variable "kafka_topics" {
  description = "Self-service topic requests keyed by a stable onboarding identifier"
  type = map(object({
    name                = string
    cluster_key         = string
    partitions          = number
    replication_factor  = number
    min_insync_replicas = number
  }))

  default = {
    orders_v1 = {
      name                = "orders.v1"
      cluster_key         = "orders"
      partitions          = 6
      replication_factor  = 3
      min_insync_replicas = 2
    }
  }

  validation {
    condition = alltrue([
      for topic in values(var.kafka_topics) : topic.partitions >= 1
    ])
    error_message = "Every Kafka topic must have at least one partition."
  }

  validation {
    condition = alltrue([
      for topic in values(var.kafka_topics) : topic.replication_factor == 3
    ])
    error_message = "Basic clusters use a replication factor of 3."
  }

  validation {
    condition = alltrue([
      for topic in values(var.kafka_topics) : topic.min_insync_replicas >= 1 && topic.min_insync_replicas <= topic.replication_factor
    ])
    error_message = "min_insync_replicas must be between 1 and the topic replication factor."
  }
}

variable "topic_producers" {
  description = "Least-privilege producer accounts keyed by a stable onboarding identifier"
  type = map(object({
    name        = string
    cluster_key = string
    topic_keys  = list(string)
  }))

  default = {
    orders_producer = {
      name        = "orders-v1-producer"
      cluster_key = "orders"
      topic_keys  = ["orders_v1"]
    }
  }
}
