import datetime
import time
import requests


temp=[{'metric': {'__name__': 'libvirt_domain_state_code', 'compute': 'tbz-sc2-compute3', 'domain': 'instance-0000620a', 'flavorName': 'plan 2', 'host': 'compute3.iranserver', 'instance': 'tbz-sc2-compute3.greenweb.local:9000', 'instanceId': '2406d72d-cdc2-4ee4-aa65-2a122f6e213236011', 'instanceName': 'testtt', 'job': 'prometheus-libvirt-exporter', 'projectId': '2782b1d5c49f45a0a8f7ad44dae62160', 'projectName': 'GreenwebCloud', 'stateDesc': 'unknown', 'userId': '6d9a01c2be6940269b850492d7a97ed1', 'userName': 'admin'}, 'value': [1650954378.601, '1']}]
PROMETHEUS = 'http://172.20.8.10:9090/'

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
      r = requests.post('https://api.gportal.app/check/service', json=results)
      r = requests.post('https://webhook.site/ebebdb5e-498b-4d7b-91ea-174e1cbcd782?', json=results)
      for result in results:
         print(' {metric}: {value[1]}'.format(**result))
         with open("/opt/libvirt_state/instances.log", "a") as file_object:
             file_object.write(' {metric}: {value[1]}'.format(**result))
