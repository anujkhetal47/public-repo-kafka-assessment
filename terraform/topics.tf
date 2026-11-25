# Preserve the existing live topic while moving it to the map-based address.
moved {
  from = confluent_kafka_topic.orders_v1
  to   = confluent_kafka_topic.onboarded["orders_v1"]
}

resource "confluent_kafka_topic" "onboarded" {
  for_each = var.kafka_topics

  kafka_cluster {
    id = confluent_kafka_cluster.onboarded[each.value.cluster_key].id
  }

  topic_name = each.value.name

  # Each topic's partition count is explicitly supplied by its self-service request.
  partitions_count = each.value.partitions

  rest_endpoint = confluent_kafka_cluster.onboarded[each.value.cluster_key].rest_endpoint
  credentials {
    key    = confluent_api_key.topic_manager_kafka[each.value.cluster_key].id
    secret = confluent_api_key.topic_manager_kafka[each.value.cluster_key].secret
  }

  config = {
    # min.insync.replicas protects against acknowledging writes when too few replicas are synchronized.
    "min.insync.replicas" = tostring(each.value.min_insync_replicas)
  }

  # replication.factor = 3: Basic clusters use three replicas and the provider manages this at cluster level.
  depends_on = [confluent_api_key.topic_manager_kafka]
}
