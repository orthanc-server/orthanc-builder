#!/usr/bin/env python3

# this scripts performs a readiness/aliveness check of orthanc by simply calling
# the /system route from inside the container.
# ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
#   

import urllib.request  # we don't use the requests module to avoid forcing installation for everyone
import sys
import json
import base64


http_port = 8042
headers = {}
user = None
pwd = None

# try to read port number + user credentials from the configuration file
try:
    with open('/tmp/orthanc.json', 'rb') as config_file:
        config = json.load(config_file)

        if 'HttpPort' in config:
            http_port = config['HttpPort']
        
        if 'AuthenticationEnabled' in config and config['AuthenticationEnabled']:
            if 'RegisteredUsers' in config and len(config['RegisteredUsers']):
                for u, p in config['RegisteredUsers'].items():
                    user = u
                    pwd = p
                    break
except:
    pass

try:
    req = urllib.request.Request(f'http://localhost:{http_port}/system')

    if user:
        base_64_credentials = base64.b64encode(bytes(f"{user}:{pwd}", 'utf-8'))
        req.add_header('Authorization', 'Basic %s' % base_64_credentials.decode('utf-8'))

    with urllib.request.urlopen(req) as f:
        if f.status == 200:
            sys.exit(0)
    
except:
    pass
sys.exit(1)
