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
   nowdate=datetime.datetime.today().isoformat()
   time.sleep(0.3)
   response=requests.get(PROMETHEUS + '/api/v1/query', params={'query': 'libvirt_domain_state_code and changes(libvirt_domain_state_code[10m]) > 0'})
   tresults = response.json()['data']['result']
   results = tresults
   if tresults==[] :
      pass
   else :
      for tresult in tresults:
         tresult["value"][0]=""
      results=tresults
   if results==[] :
      pass
   if results == temp  :
      pass

   else:
      temp=results
      try:
         r = requests.post('https://my.webhook', json=results)
      except:
         print('Occurred an error to Post Values to Webhook. Please Check Connectivity.')
         with open("/opt/libvirt_state/instances.log", "a") as file_object:
             file_object.write(f'\n {nowdate} Occurred an error to Post Values to Webhook. Please Check Connectivity. \n ')

      for result in results:
         print(' {metric}: {value[1]}'.format(**result))
         with open("/opt/libvirt_state/instances.log", "a") as file_object:
             file_object.write(f'\n {nowdate} : ')
             file_object.write('{metric}: {value[1]}'.format(**result))
EOF

systemctl daemon-reload
systemctl enable libvirt_state
systemctl start libvirt_state
