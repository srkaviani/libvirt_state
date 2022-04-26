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


temp=[{'metric': {'__name__': 'libvirt_domain_state_code', 'compute': 'testcompute', 'domain': 'instance-xxxxxxxx', 'flavorName': 'plan x', 'host': 'testcompute.local', 'instance': 'testcompute:9000', 'instanceId': 'xxxx-xxx-xxxx-xxxx-xxxx', 'instanceName': 'test', 'job': 'prometheus-libvirt-exporter', 'projectId': 'xxxxxxxxxxxxxxxxxxxxxxxxxx', 'projectName': 'myCloud', 'stateDesc': 'unknown', 'userId': 'xxxxxxxxxxxxxxxxxxx', 'userName': 'test'}, 'value': [1650954378.601, '1']}]
PROMETHEUS = 'http://prometheus.local:9090/'

while(True):
   time.sleep(1)
   response=requests.get(PROMETHEUS + '/api/v1/query', params={'query': 'libvirt_domain_state_code and changes(libvirt_domain_state_code[1m]) > 0'})
   results = response.json()['data']['result']
   if results==[] :
      pass
   elif results[0]["metric"]["instanceId"] == temp[0]["metric"]["instanceId"] and results[0]["value"][1] == temp[0]["value"][1]  :
      pass
   else:
      temp=results
      r = requests.post('https://webhook.test', json=results)
      for result in results:
         print(' {metric}: {value[1]}'.format(**result))
EOF

systemctl daemon-reload
systemctl enable libvirt_state
systemctl start libvirt_state
