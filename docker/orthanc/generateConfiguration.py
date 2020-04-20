import os
import re
import glob
import json
import typing
import tempfile
import subprocess

from helpers import JsonPath, logInfo, logWarning, logError, removeCppCommentsFromJson, isEnvVarDefinedEmptyOrTrue, enableVerboseModeForConfigGeneration
from configurator import OrthancConfigurator

#os.environ["DEBUG"]="true"
if os.environ.get("DEBUG", "false") == "true":  # for dev only -> to remove
  os.environ["VERBOSE_STARTUP"] = "true"

  os.environ["ORTHANC__QUERY_RETRIEVE_SIZE"] = "1"
  os.environ["ORTHANC__DICOM_AET"] = "ORTHANC_ENV"
  os.environ["ORTHANC__CASE_SENSITIVE_PN"] = "false"
  os.environ["PG_PASSWORD"] = "pg-password"
  os.environ["PG_HOST"] = "host"

  # os.environ["ORTHANC__PKCS11__MODULE"] = "tutu"
  os.environ["AZSTOR_ACC_NAME"] = "tito"
  os.environ["WL_ENABLED"] = ""
  os.environ["WVB_ALPHA_ENABLED"] = ""
  os.environ["ORTHANC__WEB_VIEWER__CACHE_ENABLED"] = "true"
  os.environ["DW_HOST"] = ""

configurator = OrthancConfigurator()

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

# parse all files in /run/secrets whose filename looks like an env-variable (i.e ORTHANC__MYSQL__PASSWORD)
envVarLikeName = re.compile("[A-Z\_]*")
legacySecret = re.compile("[A-Z\_]*_SECRET$")

for secretPath in glob.glob("/run/secrets/*"):
  logInfo("secret: " + secretPath)

  with open(secretPath, "r") as fp:
    secretValue = fp.read()

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
