import datetime
import time
import requests
PROMETHEUS = 'http://prometheus.com:9090/'
tempresponse=requests.get(PROMETHEUS + '/api/v1/query', params={'query': 'libvirt_domain_state_code'})
temp=tempresponse.json()['data']['result']
instances = {}
t_instances = {}
for tresult in temp:
   t_instances[f"{tresult['metric']['instanceId']}"] = tresult['metric']['flavorName']
while(True):
   instances = {}
   time.sleep(1)
   response=requests.get(PROMETHEUS + '/api/v1/query', params={'query': 'libvirt_domain_state_code'})
   results = response.json()['data']['result']
   for result in results:
       instances[f"{result['metric']['instanceId']}"] = result['metric']['flavorName']
   if instances == t_instances  :
       pass
   else:
      for instance,t in zip(instances,t_instances) :
          if instances.get(instance) != t_instances.get(instance):
             if t_instances.get(instance) == None :
                print("New Server Created. Instance Name= ",instance," New Plan: ",instances.get(instance)," Old Plan: ", t_instances.get(instance),"\n")
             else :
                print("Flavor Changed. Instance Name= ",instance," New Plan: ",instances.get(instance)," Old Plan: ", t_instances.get(instance),"\n")
      t_instances = instances
