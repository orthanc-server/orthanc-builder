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
      logError(f"Unable to parse Json file '{filePath}'; check syntax")
    
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
  logError("************* you are using deprecated settings, these settings are deprecated since April 2020 !!!  Starting from July 2026, Orthanc will refuse to start as long as you are still using these deprecated variables *************")
  logError("** List of deprecated settings: ")
  for s in configurator.deprecatedSettings:
    logError(f"** {s}")
  exit(-2)

if configurator.hasErrors:
  logError("There were some errors while preparing the configuration file for Orthanc.")
  exit(-1)

# check if there are RegisteredUsers and create a default orthanc user if required
config = configurator.configuration

orthanc_password = os.environ.get('ORTHANC_PASSWORD')
if orthanc_password is not None and len(orthanc_password) > 0:
  if 'RegisteredUsers' not in config or len(config['RegisteredUsers']) == 0:
    config["RegisteredUsers"] = {
        'orthanc': orthanc_password
      }
  else:
    config["RegisteredUsers"]["orthanc"] = orthanc_password

# Authentication and RemoteAccessAllowed are true and RegisteredUsers are empty -> Orthanc will refuse to start.
if ('RemoteAccessAllowed' not in config or config['RemoteAccessAllowed']) and ('AuthenticationEnabled' not in config or config['AuthenticationEnabled']):
    if 'RegisteredUsers' not in config or len(config['RegisteredUsers']) == 0:
      logError("********** HTTP authentication is enabled and Remote Access is allowed, but no user is declared.  "
               "Starting with Orthanc 1.13.0, you must at least explicitly declare one user in the configuration option \"RegisteredUsers\". "
               "As an alternative, you may define the -e ORTHANC_PASSWORD=change-me environment variable to define an 'orthanc' user with the given password. "
               "Or you may also use -e ORTHANC__AUTHENTICATION_ENABLED=false to allow access to Orthanc without any authentication.  This is *not* recommended.")
      exit(-3)

configFilePath="/tmp/orthanc.json"
logInfo("generating temporary configuration file in " + configFilePath)
with open(configFilePath, "w+t") as fp:
  json.dump(config, fp=fp, indent=2)
