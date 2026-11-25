# Rolling Kafka broker configuration

This play sets `num.replica.fetchers=4` in `server.properties`, restarting each broker one at a time.

## Safety behavior

- `serial: 1` limits rollout to one broker per play batch.
- `lineinfile` changes only the target setting and creates a backup before edits.
- A broker restarts only when the setting actually changes.
- Before restart, `kafka-topics --describe --under-replicated-partitions` must return no partitions.
- After restart, the broker listener and under-replicated partition count are checked again.
- No credentials are stored in the role.

## Inventory and variables

Update `inventory.ini` for your broker hostnames, bootstrap servers, Kafka paths, service name, and listener port.
Override defaults as needed:

```yaml
num_replica_fetchers: 4
kafka_server_properties: /opt/kafka/config/server.properties
kafka_service_name: kafka
kafka_bootstrap_servers: broker1:9092,broker2:9092,broker3:9092
```

For secured brokers, set `kafka_topics_extra_args` to Kafka CLI authentication options such as `['--command-config', '/secure/kafka-client.properties']`. Store the command config with Ansible Vault or a protected host-specific path; never commit credentials.

## Dry run

```powershell
cd ansible
ansible-playbook -i inventory.ini site.yml --check --diff
```

Check mode reports whether the setting would change and must not restart a live broker.

## Apply

```powershell
ansible-playbook -i inventory.ini site.yml
```

Run against a maintenance window and verify broker state in your Kafka monitoring system.
