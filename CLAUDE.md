# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Ansible playbooks for deploying and managing Redis Sentinel clusters with HAProxy. Targets Ubuntu (tested with Ubuntu 22/Jammy). All hosts connect as root via custom SSH ports.

## Common Commands

All commands use `--check` for dry-run. Remove `--check` to apply changes.

```bash
# Initial setup: install Redis/Sentinel packages, create user, tune sysctl
ansible-playbook -i inventory/dev/hosts.ini -l redis_test playbooks/redis-sentinel-setup.yml --check

# Configure a specific Redis port (pass vars file with -e @)
ansible-playbook -i inventory/dev/hosts.ini -l redis_test playbooks/redis-sentinel-config.yml -e @vars/dev/redis_test/redis-port-6800.yml --check

# Deploy/update HAProxy
ansible-playbook -i inventory/dev/hosts.ini -l redis_test playbooks/haproxy.yml --check

# Update HAProxy config only
ansible-playbook -i inventory/dev/hosts.ini -l redis_test playbooks/haproxy.yml --tags "haproxy_conf" --check
```

## Architecture

### Two-phase deployment model

The `redis-sentinel` role has two phases controlled by boolean vars (`redis_setup` / `redis_config`), toggled by the calling playbook:

1. **Setup** (`playbooks/redis-sentinel-setup.yml` -> `roles/redis-sentinel/tasks/setup.yml`): One-time per host. Installs Redis packages at a pinned version, creates redis user/group, tunes `vm.overcommit_memory`, creates data/config directories, disables default Redis services.
2. **Config** (`playbooks/redis-sentinel-config.yml` -> `roles/redis-sentinel/tasks/config.yml`): Per-port. Deploys Redis server, Sentinel, and redis_exporter for a specific port. Requires a vars file (`-e @vars/...`) defining port-specific settings. Within config, `install_redis` and `install_sentinel` booleans (set in host_vars) control which components deploy per host.

### Port numbering convention

Each Redis instance uses a calculated set of 4 ports (do not use ports > 10000):
- Redis: `6800`, Sentinel: `8800`, HAProxy: `7800`, Exporter: `9800`
- Next instance: `6801`, `8801`, `7801`, `9801`, etc.

### Inventory and variable layering

- `inventory/{env}/hosts.ini` — host groups and connection settings
- `inventory/{env}/group_vars/` — shared config per host group (Redis version, paths, HAProxy config file path)
- `inventory/{env}/host_vars/` — per-host flags: `install_redis`, `install_sentinel`, `role` (master/slave), `masterHost`
- `vars/{env}/{group}/redis-port-XXXX.yml` — per-port instance config (service name, passwords, memory limits, Telegram alerting)

### HAProxy role

Static config files live in `roles/haproxy/files/{env}/{group}/haproxy.cfg`. To add a new Redis port to HAProxy, edit the config file directly in the repo, then run the haproxy playbook.

### Sentinel notifications

Sentinel failover events trigger a Python notification script (`roles/redis-sentinel/templates/notify_redis.py.j2`) that sends alerts to Telegram.
