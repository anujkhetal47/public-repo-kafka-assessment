# Assessment notes

## Deliberately skipped or deferred

- No live broker rebuild or Confluent Dedicated GCP PSC cluster was requested or deployed; the Terraform work targets the permitted Confluent Cloud Basic cluster and assumes access to live credentials for apply.
- The GCP PSC answer is architectural because no GCP project, DNS zone, forwarding rule, or Dedicated cluster was available.
- The Ansible inventory contains example broker hostnames and paths; it is intended for review and dry-run syntax/idempotence, not execution against real brokers.
- The lag script is tested with live Confluent Cloud missing-group and broker-unreachable cases. A positive multi-partition live test would require additional consumer assignments or produced records across partitions.
- Credential values and Terraform state are deliberately not committed. They belong in environment variables or gitignored `terraform.tfvars`.

## AI usage

- GitHub Copilot / MAI Code 2 Flash was used to draft and structure the Terraform, Ansible, Python, and written assessment files.
- The final code and write-ups were reviewed locally before submission. Technical choices and assessment answers were checked against the implementation and requirements in this repository.
- Code testing and validation were performed locally: `terraform validate`, live Terraform plans/applies and a no-change follow-up plan, Python compile and negative/live lag tests, and YAML parsing for Ansible.
- Live testing used temporary test resources or gitignored credentials where possible. No credentials or Terraform state are included in the repository.
