### Redis Sentinel guide
- Design example
```
# Setup base: Redis / Sentinel package and lock them to specific version + tunning sysctl: vm.overcommit_memory = 1 + rest....
ansible-playbook -i inventory/dev/hosts.ini -l redis_test playbooks/redis-sentinel-setup.yaml

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
ansible-playbook -i inventory/dev/hosts.ini -l redis_test playbooks/redis-sentinel-config.yaml -e @vars/dev/redis_test/redis-port-6800.yml

# Setup Haproxy: we have to edit haproxy.cfg in ansible repo
ansible-playbook -i inventory/dev/hosts.ini -l redis_test playbooks/haproxy.yaml --check
# for Update haproxy cfg only
ansible-playbook -i inventory/dev/hosts.ini -l redis_test playbooks/haproxy.yaml --tags "haproxy_conf" --check
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
inventory/dev/group_vars/redis_test.yaml
```

- Add new port 
```
Add new file with correct env and host tag:
example: vars/dev/redis_test/redis-port-68xx.yml
```



- Run Example 
```
ansible-playbook -i inventory/dev/hosts.ini -l redis_test playbooks/redis-sentinel-setup.yaml --check

ansible-playbook -i inventory/dev/hosts.ini -l redis_test playbooks/redis-sentinel-config.yaml -e @vars/dev/redis_test/redis-port-6800.yml --check
```

