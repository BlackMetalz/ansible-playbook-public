### Ansible Convention

- snake_case for variable.

### Redis Sentinel guide
- Design example
```
# Setup base: Redis / Sentinel package and lock them to specific version + tunning sysctl: vm.overcommit_memory = 1 + rest....
ansible-playbook -i inventory/dev/hosts.ini -l redis_test playbooks/redis-sentinel-setup.yml

# Setup up first port. Prefer 6800 and follow ( this shit have been calculated serveral times to get this )
# We should not use port > 10000 to prevent some rare case happens that we can not bind service on port which is already used!
- Redis Port: 6800
- Haproxy Port: 7800
- Sentinel Port: 8800
- Redis Exporter: 9800
And so on for next port
- Redis Port: 6801
- Haproxy Port: 7801
- Sentinel Port: 8801
- Redis Exporter: 9801
# Example for config specific port
ansible-playbook -i inventory/dev/hosts.ini -l redis_test playbooks/redis-sentinel-config.yml -e @vars/dev/redis_test/redis-port-6800.yml

# Setup Haproxy: we have to edit haproxy.cfg in ansible repo
ansible-playbook -i inventory/dev/hosts.ini -l redis_test playbooks/haproxy.yml --check
# for Update haproxy cfg only
ansible-playbook -i inventory/dev/hosts.ini -l redis_test playbooks/haproxy.yml --tags "haproxy_conf" --check
ansible-playbook -l redisTest haproxy.yml --tags "haproxy_conf"
# And more option with tag in ansible-redis deployment repo
```

- Define which host is redis-server/sentinel in here:
```
# Example
inventory/dev/host_vars/redis_1.yml ....
```

- Want to change some global config for host tag `redis_test.yml`
```
inventory/dev/group_vars/redis_test.yml
```

- Add new port 
```
Add new file with correct env and host tag:
example: vars/dev/redis_test/redis-port-68xx.yml
```



- Run Example
```
ansible-playbook -i inventory/dev/hosts.ini -l redis_test playbooks/redis-sentinel-setup.yml --check

ansible-playbook -i inventory/dev/hosts.ini -l redis_test playbooks/redis-sentinel-config.yml -e @vars/dev/redis_test/redis-port-6800.yml --check
```

---

### User Management guide

Manage SSH users across all products. Only 2 places to configure:

| Where | What | File |
|-------|------|------|
| **Who is the user?** | Name, SSH key, password | `vars/users.yml` + `vars/users_passwords.yml` |
| **Where and what access?** | Which host, sudo or not | `inventory/product-X/hosts` |

Full guide with Vietnamese instructions: [docs/add_user_vi.md](docs/add_user_vi.md)

#### Inventory format
```ini
[all]
host-1 ansible_host=10.0.0.1  sudoers=kienlt members=kienlt,hieupn,dev1
host-2 ansible_host=10.0.0.2  sudoers=kienlt members=kienlt,hieupn
host-3 ansible_host=10.0.0.3  sudoers=kienlt,dba members=kienlt,dba,dev1
```

- `members` = users with SSH access to this host (comma-separated)
- `sudoers` = users with sudo privilege, **must also be in `members`**

#### Master list `vars/users.yml`
```yaml
all_managed_users:
  - name: kienlt
    ssh_key: "ssh-ed25519 AAAA..."
  - name: hieupn
    ssh_key: "ssh-ed25519 BBBB..."

removed_users: []
```

#### Run
```bash
# Dry-run
ansible-playbook -i inventory/product-X/hosts playbooks/manage-users.yml --check --ask-vault-pass

# Apply
ansible-playbook -i inventory/product-X/hosts playbooks/manage-users.yml --ask-vault-pass

# Single host
ansible-playbook -i inventory/product-X/hosts -l host-1 playbooks/manage-users.yml --ask-vault-pass
```

#### Delete users (separate playbook for safety)
```bash
# Add user to removed_users in vars/users.yml, then:
ansible-playbook -i inventory/product-X/hosts playbooks/delete-users.yml --check
ansible-playbook -i inventory/product-X/hosts playbooks/delete-users.yml
```

#### Vault guide - Manage passwords
```bash
# Generate password hash
./scripts/generate-password.sh

# Edit passwords (decrypt -> edit -> re-encrypt on save)
ansible-vault edit vars/users_passwords.yml

# First-time encrypt
ansible-vault encrypt vars/users_passwords.yml

# View without editing
ansible-vault view vars/users_passwords.yml
```

Optional: skip `--ask-vault-pass` every time:
```bash
echo 'your_vault_password' > ~/.vault_pass
chmod 600 ~/.vault_pass
# Add to ansible.cfg: vault_password_file = ~/.vault_pass
```

