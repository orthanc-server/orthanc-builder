import orthanc
import pprint
import os

import threading
import requests

TIMER = None
TOKEN = orthanc.GenerateRestApiAuthorizationToken()


def generate_core():
    print("Generating core")
    os.system("cd /cores && gcore $(pidof Orthanc)")


def JobsRouteMonitoring():
    global TIMER
    TIMER = None

    is_alive = False
    try:
        orthanc.LogWarning("Monitoring /jobs route to check it is still responding")

        r = requests.get('http://localhost:8042/jobs',
                     headers = { 'Authorization' : TOKEN })
        is_alive = True

    except Exception as ex:
        orthanc.LogWarning("Monitoring /jobs exception: " + str(ex))
    
    if not is_alive:
        generate_core()


    TIMER = threading.Timer(1, JobsRouteMonitoring)  # Re-schedule after 10 seconds
    TIMER.start()


def OnChange(changeType, level, resource):
    if changeType == orthanc.ChangeType.ORTHANC_STARTED:
        orthanc.LogWarning("Starting the scheduler")
        JobsRouteMonitoring()

    elif changeType == orthanc.ChangeType.ORTHANC_STOPPED:
        if TIMER != None:
            orthanc.LogWarning("Stopping the scheduler")
            TIMER.cancel()



def OnRestGenerateCore(output, uri, **request):
    generate_core()
    output.AnswerBuffer('ok\n', 'text/plain')

orthanc.RegisterRestCallback('/generate-core', OnRestGenerateCore)

