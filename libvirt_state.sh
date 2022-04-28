#!/bin/bash
echo '[Unit]
Description=Test Service
After=multi-user.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /opt/libvirt_state/app.py
StandardInput=tty-force

[Install]
WantedBy=multi-user.target' > /etc/systemd/system/libvirt_state.service
mkdir /opt/libvirt_state
cat << EOF > /opt/libvirt_state/app.py
import datetime
import time
import requests


temp=[{'metric': {'__name__': 'libvirt_domain_state_code', 'compute': 'test-compute3', 'domain': 'instance-xxxxxxx', 'flavorName': 'plan x', 'host': 'compute3.test', 'instance': 'test3.local:9000', 'instanceId': 'xxxxxx-xxxxx-4eex4-xxxx-xxxxxxxxxx', 'instanceName': 'testtt', 'job': 'libvirt-exporter', 'projectId': 'xxxxxxxxxxxxxxxx', 'projectName': 'myCloud', 'stateDesc': 'unknown', 'userId': 'xxxxxxxxxxxxxxxxxx', 'userName': 'test'}, 'value': [1650954378.601, '1']}]
PROMETHEUS = 'http://PROMETHEUS.local:9090/'

while(True):
   time.sleep(1)
   response=requests.get(PROMETHEUS + '/api/v1/query', params={'query': 'libvirt_domain_state_code and changes(libvirt_domain_state_code[10m]) > 0'})
   results = response.json()['data']['result']
   if results==[] :
      pass
   elif results[0]["metric"]["instanceId"] == temp[0]["metric"]["instanceId"] and results[0]["value"][1] == temp[0]["value"][1]  :
      pass
   else:
      temp=results
      r = requests.post('https://my.webhook', json=results)
      for result in results:
         print(' {metric}: {value[1]}'.format(**result))
         with open("/opt/libvirt_state/instances.log", "a") as file_object:
             file_object.write(' {metric}: {value[1]}'.format(**result))
EOF

systemctl daemon-reload
systemctl enable libvirt_state
systemctl start libvirt_state
