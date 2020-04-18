import os
import re
import glob
import json
import typing
import tempfile
import subprocess

from helpers import JsonPath, logInfo, logWarning, logError, removeCppCommentsFromJson, isEnvVarDefinedEmptyOrTrue, enableVerboseModeForConfigGeneration
from configurator import OrthancConfigurator

os.environ["DEBUG"]="true"
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

logInfo("TODO REMOVE Discovering configuration files from ./docker/orthanc-builder-all/tmp/*.json")
for filePath in glob.glob("./docker/orthanc-builder-all/tmp/*.json"):
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


################# enable plugins and apply their defaults ################################


# for pluginName, pluginDef in plugins.items():
  
#   if "section" in pluginDef:
#     section = pluginDef["section"]
#   else:
#     section = pluginName

#   enabled = section in configurator.configuration

#   # multiple plugins can have the same section (i.e: the web-viewers)
#   # so they need to have one of their enabling env var set to true
#   if pluginDef["enablingEnvVarIsRequired"]:
#     enabled = False
#   else:
#     # for other plugins, if at least one setting of the plugin section has been defined,
#     # it is considered as enabled
#     enabled = section in configurator.configuration

#   if "enablingEnvVar" in pluginDef and isEnvVarDefinedEmptyOrTrue(pluginDef["enablingEnvVar"]):
#     enabled = True
  
#   if "enablingEnvVarLegacy" in pluginDef and isEnvVarDefinedEmptyOrTrue(pluginDef["enablingEnvVarLegacy"]):
#     enabled = True
#     logWarning("You're using a deprecated env-var to enable the {p} plugin, you should use {n} instead of {o}".format(
#       p=pluginName,
#       n=pluginDef["enablingEnvVar"],
#       o=pluginDef["enablingEnvVarLegacy"]
#     ))
#     hasDeprecatedSettings = True

#   if enabled:
#     # copy defaults config and move the plugin.so into the right folder

#     logInfo("Enabling {p} plugin".format(p = pluginName))
    
#     if "nonStandardDefaults" in plugins[pluginName]:

#       pluginDefaultConfig = {
#         section: plugins[pluginName]["nonStandardDefaults"]
#       }
#       configurator.mergeConfigFromDefaults(pluginDefaultConfig, pluginName)
    
#     if "libs" in pluginDef:
#       for lib in pluginDef["libs"]:
#         try:
#           os.rename("/usr/share/orthanc/plugins-disabled/" + lib, "/usr/share/orthanc/plugins/" + lib)
#         except:
#           logError("failed to move {l} file".format(l = lib))
#           hasErrors = True
#   else:
#     logInfo("{p} won't be enabled, no configuration found for this plugin".format(p = pluginName))

logInfo("generated configuration file: " + json.dumps(configurator.configuration, indent=2))

if configurator.hasDeprecatedSettings:
  logWarning("************* you are using deprecated settings, these deprecated settings will be removed in June 2021 *************")

if configurator.hasErrors:
  logError("There were some errors while preparing the configuration file for Orthanc.")
#  exit(-1)


configFilePath="/tmp/orthanc.json"
logInfo("generating temporary configuration file in " + configFilePath)
with open(configFilePath, "w+t") as fp:
  json.dump(configurator.configuration, fp=fp, indent=2)


# cmd = ["Orthanc"]
# if isEnvVarDefinedEmptyOrTrue("TRACE_ENABLED"):
#   cmd.append("--trace")
# elif isEnvVarDefinedEmptyOrTrue("VERBOSE_ENABLED"):
#   cmd.append("--verbose")
  

# cmd.append(tmpConfigFile.name)
  
# orthancProcess = subprocess.Popen(cmd, stdout=subprocess.PIPE)
# orthancProcess.wait()
# for line in orthancProcess.stdout:
#   print(line)
# print(orthancProcess.returncode)
#orthancProcess = subprocess.run(cmd, capture_output=True)

