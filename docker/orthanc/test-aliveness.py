#!/usr/bin/env python3

# this scripts performs a readiness/aliveness check of orthanc by simply calling
# the /system route from inside the container.
# ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
# when using mTLS at Orthanc level, it is impossible to use the built-in K8 HttpGet probes hence this script.
#
# usage:
# ./test-aliveness.py --http_port=8042 --user=toto --pwd=tutu --http_scheme=http --certfile=/my/client.cert.pem --keyfile=/my/client.key.pem --keypwd=mykeypwd
#    the http_port, http_scheme, user and pwd arguments are extracted from the orthanc configuration file if not provided.
#    check https://docs.python.org/3/library/ssl.html#ssl.SSLContext.load_cert_chain for more details about the 3 cert arguments

import urllib.request  # we don't use the requests module to avoid forcing installation for everyone
import sys
import json
import base64
import ssl
import argparse
import traceback


http_port = 8042
headers = {}
user = None
pwd = None
certfile = None
keyfile = None
keypwd = None
http_scheme = 'http'

parser = argparse.ArgumentParser()
parser.add_argument('--http_port', type=int)
parser.add_argument('--http_scheme', type=str)
parser.add_argument('--user', type=str)
parser.add_argument('--pwd', type=str)
parser.add_argument('--certfile', type=str)
parser.add_argument('--keyfile', type=str)
parser.add_argument('--keypwd', type=str)

args = parser.parse_args()

# first try to read port number + user credentials from the configuration file
try:
    with open('/tmp/orthanc.json', 'rb') as config_file:
        config = json.load(config_file)

        if 'HttpPort' in config:
            http_port = config['HttpPort']

        if 'AuthenticationEnabled' in config and config['AuthenticationEnabled']:
            if 'RegisteredUsers' in config and len(config['RegisteredUsers']):
                if args.user:
                    pwd = config['RegisteredUsers'].get(args.user, '')
                else:
                    for u, p in config['RegisteredUsers'].items():
                        user = u
                        pwd = p
                        break

        if 'SslEnabled' in config and config['SslEnabled']:
            http_scheme = 'https'

except:
    pass


# override the values from the config file with the values from the command line

if args.http_port:
    http_port = args.http_port

if args.user:
    user = args.user

if args.pwd:
    pwd = args.pwd

if args.http_scheme:
    http_scheme = args.http_scheme

if args.certfile:
    certfile = args.certfile
    http_scheme = 'https'

if args.keyfile:
    keyfile = args.keyfile

if args.keypwd:
    keypwd = args.keypwd

try:
    ssl_context = None
    ssl_context = ssl.SSLContext()
    ssl_context.verify_mode = ssl.CERT_NONE  # skip verification of server cert

    if certfile:
        ssl_context.load_cert_chain(certfile=certfile, keyfile=keyfile, password=keypwd)

    req = urllib.request.Request(f'{http_scheme}://localhost:{http_port}/system')

    if user and pwd:
        base_64_credentials = base64.b64encode(bytes(f"{user}:{pwd}", 'utf-8'))
        req.add_header('Authorization', 'Basic %s' % base_64_credentials.decode('utf-8'))

    with urllib.request.urlopen(req, context=ssl_context) as f:
        if f.status == 200:
            sys.exit(0)

except Exception:
    print(traceback.format_exc())
sys.exit(1)
