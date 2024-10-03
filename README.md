### Redis Sentinel guide

ansible-playbook -i inventory/dev/hosts.ini -l redis_test playbooks/redis-sentinel-setup.yaml --check

ansible-playbook -i inventory/dev/hosts.ini -l redis_test playbooks/redis-sentinel-config.yaml -e @vars/dev/redis_test/redis-port-6800.yml --check