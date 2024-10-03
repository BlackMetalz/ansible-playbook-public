### Output example:

- for Setup
```
ansible-playbook -i inventory/dev/hosts.ini -l redis_test playbooks/redis-sentinel-setup.yaml --check
PLAY [all] *********************************************************************************************************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************************************************************************************
ok: [redis_2]
ok: [redis_3]
ok: [redis_1]

TASK [redis-sentinel : Include setup tasks] ************************************************************************************************************************************************************************
included: /data/github.com/ansible-playbook-public/roles/redis-sentinel/tasks/setup.yml for redis_1, redis_2, redis_3

TASK [redis-sentinel : Ensure vm.overcommit_memory is set to 1] ****************************************************************************************************************************************************
ok: [redis_3]
ok: [redis_2]
ok: [redis_1]

TASK [redis-sentinel : Persist vm.overcommit_memory setting] *******************************************************************************************************************************************************
ok: [redis_2]
ok: [redis_3]
ok: [redis_1]

TASK [redis-sentinel : Ensure redis user and group exist] **********************************************************************************************************************************************************
ok: [redis_3]
ok: [redis_2]
ok: [redis_1]

TASK [redis-sentinel : Ensure redis user exists] *******************************************************************************************************************************************************************
ok: [redis_2]
ok: [redis_3]
ok: [redis_1]

TASK [redis-sentinel : Add redis signing key] **********************************************************************************************************************************************************************
ok: [redis_2]
ok: [redis_3]
ok: [redis_1]

TASK [redis-sentinel : Add redis repo] *****************************************************************************************************************************************************************************
ok: [redis_3]
ok: [redis_2]
ok: [redis_1]

TASK [redis-sentinel : Install specific version of redis-server, redis-sentinel and redis-tools 6:6.2.14-1rl1~jammy1] **********************************************************************************************
ok: [redis_2]
ok: [redis_3]
ok: [redis_1]

TASK [redis-sentinel : Install python3-pip for script notify] ******************************************************************************************************************************************************
ok: [redis_2]
ok: [redis_3]
ok: [redis_1]

TASK [redis-sentinel : Hold redis-server package] ******************************************************************************************************************************************************************
skipping: [redis_2]
skipping: [redis_3]
skipping: [redis_1]

TASK [redis-sentinel : Hold redis-tools package] *******************************************************************************************************************************************************************
skipping: [redis_2]
skipping: [redis_1]
skipping: [redis_3]

TASK [redis-sentinel : Hold redis-sentinel package] ****************************************************************************************************************************************************************
skipping: [redis_2]
skipping: [redis_1]
skipping: [redis_3]

TASK [redis-sentinel : Stop, disable service redis-server default] *************************************************************************************************************************************************
ok: [redis_2]
ok: [redis_3]
ok: [redis_1]

TASK [redis-sentinel : Stop, disable service redis-sentinel default] ***********************************************************************************************************************************************
ok: [redis_2]
ok: [redis_3]
ok: [redis_1]

TASK [redis-sentinel : create dataDir for Redis data] **************************************************************************************************************************************************************
ok: [redis_2]
ok: [redis_3]
ok: [redis_1]

TASK [redis-sentinel : create configDir for Redis config] **********************************************************************************************************************************************************
ok: [redis_2]
ok: [redis_3]
ok: [redis_1]

TASK [redis-sentinel : Include config tasks] ***********************************************************************************************************************************************************************
skipping: [redis_1]
skipping: [redis_2]
skipping: [redis_3]

PLAY RECAP *********************************************************************************************************************************************************************************************************
redis_1                    : ok=14   changed=0    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0   
redis_2                    : ok=14   changed=0    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0   
redis_3                    : ok=14   changed=0    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0   
```

- for config specific port
```
ansible-playbook -i inventory/dev/hosts.ini -l redis_test playbooks/redis-sentinel-config.yaml -e @vars/dev/redis_test/redis-port-6800.yml

PLAY [all] *********************************************************************************************************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************************************************************************************
ok: [redis_2]
ok: [redis_3]
ok: [redis_1]

TASK [redis-sentinel : Include setup tasks] ************************************************************************************************************************************************************************
skipping: [redis_1]
skipping: [redis_2]
skipping: [redis_3]

TASK [redis-sentinel : Include config tasks] ***********************************************************************************************************************************************************************
included: /data/github.com/ansible-playbook-public/roles/redis-sentinel/tasks/config.yml for redis_1, redis_2, redis_3

TASK [redis-sentinel : Update redis config 6800-redis-svc-name-1.conf with template for port 6800] *****************************************************************************************************************
skipping: [redis_3]
changed: [redis_2]
changed: [redis_1]

TASK [redis-sentinel : Render redis-server service template for port 6800] *****************************************************************************************************************************************
skipping: [redis_3]
changed: [redis_2]
changed: [redis_1]

TASK [redis-sentinel : Enable and start redis-server-6800 service svc-name-1] **************************************************************************************************************************************
skipping: [redis_3]
ok: [redis_2]
ok: [redis_1]

TASK [redis-sentinel : Wait Redis port 6800 Started] ***************************************************************************************************************************************************************
skipping: [redis_3]
ok: [redis_2]
ok: [redis_1]

TASK [redis-sentinel : Download Redis exporter version 1.62.0] *****************************************************************************************************************************************************
skipping: [redis_3]
changed: [redis_2]
changed: [redis_1]

TASK [redis-sentinel : Extract Redis exporter] *********************************************************************************************************************************************************************
skipping: [redis_3]
changed: [redis_2]
changed: [redis_1]

TASK [redis-sentinel : Move Redis exporter binary to /usr/local/bin] ***********************************************************************************************************************************************
skipping: [redis_3]
ok: [redis_2]
ok: [redis_1]

TASK [redis-sentinel : Create Redis exporter systemd service for redis-exporter-6800 on exporter port 9800] ********************************************************************************************************
skipping: [redis_3]
changed: [redis_2]
changed: [redis_1]

TASK [redis-sentinel : Enable and start redis-exporter-6800 service on exporter port 9800] *************************************************************************************************************************
skipping: [redis_3]
ok: [redis_1]
ok: [redis_2]

TASK [redis-sentinel : Setup notify script for Redis sentinel 8800-sentinel-svc-name-1 8800 with template] *********************************************************************************************************
changed: [redis_2]
changed: [redis_3]
changed: [redis_1]

TASK [redis-sentinel : Update sentinel config sentinel-svc-name-1.conf with template for sentinel port 8800] *******************************************************************************************************
changed: [redis_2]
changed: [redis_3]
changed: [redis_1]

TASK [redis-sentinel : Render redis-sentinel service template for port 8800] ***************************************************************************************************************************************
changed: [redis_2]
changed: [redis_3]
changed: [redis_1]

TASK [redis-sentinel : Enable and start redis-sentinel-8800 service] ***********************************************************************************************************************************************
ok: [redis_2]
ok: [redis_3]
ok: [redis_1]

TASK [redis-sentinel : Wait Redis sentinel port 8800 Started] ******************************************************************************************************************************************************
ok: [redis_2]
ok: [redis_1]
ok: [redis_3]

RUNNING HANDLER [redis-sentinel : Reload systemd daemon after rendering redis-server service template] *************************************************************************************************************
ok: [redis_2]
ok: [redis_1]

RUNNING HANDLER [redis-sentinel : Reload systemd daemon after rendering redis-sentinel service template svc-name-1] ************************************************************************************************
ok: [redis_2]
ok: [redis_3]
ok: [redis_1]

RUNNING HANDLER [redis-sentinel : Reload systemd daemon for Redis exporter] ****************************************************************************************************************************************
ok: [redis_2]
ok: [redis_1]

PLAY RECAP *********************************************************************************************************************************************************************************************************
redis_1                    : ok=19   changed=8    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
redis_2                    : ok=19   changed=8    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
redis_3                    : ok=8    changed=3    unreachable=0    failed=0    skipped=10   rescued=0    ignored=0   
```


- Haproxy playbook output example
```
ansible-playbook -i inventory/dev/hosts.ini -l redis_test playbooks/haproxy.yaml 
PLAY [all] *********************************************************************************************************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************************************************************************************
ok: [redis_2]
ok: [redis_3]
ok: [redis_1]

TASK [haproxy : Install HAProxy] ***********************************************************************************************************************************************************************************
ok: [redis_2]
ok: [redis_3]
ok: [redis_1]

TASK [haproxy : Hold HAProxy package] ******************************************************************************************************************************************************************************
skipping: [redis_2]
skipping: [redis_1]
skipping: [redis_3]

TASK [haproxy : Update HAProxy configuration file] *****************************************************************************************************************************************************************
changed: [redis_2]
changed: [redis_3]
changed: [redis_1]

TASK [haproxy : Enable HAProxy service] ****************************************************************************************************************************************************************************
ok: [redis_2]
ok: [redis_3]
ok: [redis_1]

TASK [haproxy : Ensure HAProxy log directory exists] ***************************************************************************************************************************************************************
ok: [redis_2]
ok: [redis_3]
ok: [redis_1]

TASK [haproxy : Ensure HAProxy log file exists with correct ownership and permissions] *****************************************************************************************************************************
changed: [redis_2]
changed: [redis_3]
changed: [redis_1]

TASK [haproxy : Update 49-haproxy.conf] ****************************************************************************************************************************************************************************
ok: [redis_2]
ok: [redis_3]
ok: [redis_1]

TASK [haproxy : Configure logrotate for HAProxy logs] **************************************************************************************************************************************************************
ok: [redis_2]
ok: [redis_3]
ok: [redis_1]

RUNNING HANDLER [haproxy : reload haproxy] *************************************************************************************************************************************************************************
changed: [redis_3]
changed: [redis_2]
changed: [redis_1]

PLAY RECAP *********************************************************************************************************************************************************************************************************
redis_1                    : ok=9    changed=3    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
redis_2                    : ok=9    changed=3    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
redis_3                    : ok=9    changed=3    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
```

- Update Haproxy and reload only
```
ansible-playbook -i inventory/dev/hosts.ini -l redis_test playbooks/haproxy.yaml --tags "haproxy_conf" 

PLAY [all] *********************************************************************************************************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************************************************************************************
ok: [redis_2]
ok: [redis_3]
ok: [redis_1]

TASK [haproxy : Update HAProxy configuration file] *****************************************************************************************************************************************************************
changed: [redis_2]
changed: [redis_3]
changed: [redis_1]

RUNNING HANDLER [haproxy : reload haproxy] *************************************************************************************************************************************************************************
changed: [redis_2]
changed: [redis_3]
changed: [redis_1]

PLAY RECAP *********************************************************************************************************************************************************************************************************
redis_1                    : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
redis_2                    : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
redis_3                    : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```