import os
import re
import glob
import json
import typing
import tempfile
import subprocess
from envsubst import envsubst

from helpers import JsonPath, logInfo, logWarning, logError, removeCppCommentsFromJson, isEnvVarDefinedEmptyOrTrue, enableVerboseModeForConfigGeneration
from configurator import OrthancConfigurator


configurator = OrthancConfigurator(folder = os.path.dirname(os.path.realpath(__file__)))

if isEnvVarDefinedEmptyOrTrue("VERBOSE_STARTUP"):
  enableVerboseModeForConfigGeneration()

if isEnvVarDefinedEmptyOrTrue("BUNDLE_DEBUG"):
  logWarning("You're using a deprecated env-var, you should use VERBOSE_STARTUP instead of BUNDLE_DEBUG")
  enableVerboseModeForConfigGeneration()
  

################# read all configuration files ################################
configFiles = []

logInfo("Discovering configuration files from /etc/orthanc/*.json")
for filePath in glob.glob("/etc/orthanc/*.json"):
  configFiles.append(filePath)

logInfo("Discovering configuration files from /run/secrets/*.json")
for filePath in glob.glob("/run/secrets/*.json"):
  configFiles.append(filePath)

for filePath in configFiles:
  logInfo("reading configuration from " + filePath)
  with open(filePath, "r") as f:
    content = f.read()
    
    # perform standard env var substitution before trying to read the json file (https://github.com/orthanc-server/orthanc-builder/issues/9)
    content = envsubst(content)
    try:
      cleanedContent = removeCppCommentsFromJson(content)
      configFromFile = json.loads(cleanedContent)
    except:
      logError("Unable to parse Json file '{f}'; check syntax".format(f = filePath))
    
    configurator.mergeConfigFromFile(configFromFile, filePath)

################# read all environment variables ################################

logInfo("Analyzing environment variables")
for envKey, envValue in os.environ.items():
  
  configurator.mergeConfigFromEnvVar(envKey, envValue)

################# read all secrets ################################

logInfo("Analyzing secrets")

for secretPath in glob.glob("/run/secrets/*"):
  logInfo("secret: " + secretPath)

  if os.path.isfile(secretPath):
    with open(secretPath, "r") as fp:
      secretValue = fp.read().rstrip("\n")

    configurator.mergeConfigFromSecret(secretPath, secretValue)

################# apply defaults that have not been set yet (from Orthanc and plugins) ################################

configurator.mergeConfigFromDefaults(moveSoFiles=True)


logInfo("generated configuration file: " + json.dumps(configurator.configuration, indent=2))

if configurator.hasDeprecatedSettings:
  logWarning("************* you are using deprecated settings, these deprecated settings will be removed in June 2021 *************")

if configurator.hasErrors:
  logError("There were some errors while preparing the configuration file for Orthanc.")
  exit(-1)


configFilePath="/tmp/orthanc.json"
logInfo("generating temporary configuration file in " + configFilePath)
with open(configFilePath, "w+t") as fp:
  json.dump(configurator.configuration, fp=fp, indent=2)
