import os
import re
import glob
import json
import typing
import tempfile
import subprocess

from helpers import OrthancConfigurator, logInfo, logWarning, logError, removeCppCommentsFromJson, isEnvVarDefinedEmptyOrTrue, enableVerboseModeForConfigGeneration

# os.environ["DEBUG"]="true"
if os.environ.get("DEBUG", "false") == "true":  # for dev only -> to remove
  os.environ["VERBOSE_STARTUP"] = "true"

  os.environ["ORTHANC__QUERY_RETRIEVE_SIZE"] = "1"
  os.environ["ORTHANC__DICOM_AET"] = "ORTHANC_ENV"
  os.environ["ORTHANC__CASE_SENSITIVE_PN"] = "false"
  # os.environ["ORTHANC__PKCS11__MODULE"] = "tutu"
  os.environ["AZSTOR_ACC_NAME"] = "tito"
  os.environ["WL_ENABLED"] = ""
  os.environ["WVB_ALPHA_ENABLED"] = ""
  os.environ["ORTHANC__WEB_VIEWER__CACHE_ENABLED"] = "true"
  os.environ["DW_HOST"] = ""

if isEnvVarDefinedEmptyOrTrue("VERBOSE_STARTUP"):
  enableVerboseModeForConfigGeneration()

if isEnvVarDefinedEmptyOrTrue("BUNDLE_DEBUG"):
  logWarning("You're using a deprecated env-var, you should use VERBOSE_STARTUP instead of BUNDLE_DEBUG")
  enableVerboseModeForConfigGeneration()
  
hasErrors = False
hasDeprecatedSettings = False

configurator = OrthancConfigurator()

nonStandardEnvVarNames = {
  # orthanc variables not following the conversion rule
  "ORTHANC__CASE_SENSITIVE_PN": "CaseSensitivePN",

  # osimis/orthanc backward compatibility
  "DICOM_AET" : "DicomAet",
  "DICOM_MODALITIES" : "DicomModalities",
  "DICOM_PORT" : "DicomPort",
  "DICOM_SCP_TIMEOUT" : "DicomScpTimeout",
  "DICOM_SCU_TIMEOUT" : "DicomScuTimeout",
  "DICOM_AET_CHECK_ENABLED" : "DicomCheckCalledAet",
  "DICOM_CHECK_MODALITY_HOST_ENABLED" : "DicomCheckModalityHost",
  "DICOM_STRICT_AET_COMPARISON_ENABLED" : "StrictAetComparison",
  "DICOM_DICOM_ALWAYS_ALLOW_ECHO_ENABLED" : "DicomAlwaysAllowEcho",
  "DICOM_DICOM_ALWAYS_ALLOW_STORE_ENABLED" : "DicomAlwaysAllowStore",
  "DICOM_UNKNOWN_SOP_CLASS_ACCEPTED" : "UnknownSopClassAccepted",
  "DICOM_SYNCHRONOUS_CMOVE" : "SynchronousCMove",
  "DICOM_QUERY_RETRIEVE_SIZE" : "QueryRetrieveSize",
  "DICOM_DICTIONARY" : "Dictionary",

  "AC_ALLOW_REMOTE" : "RemoteAccessAllowed",
  "AC_AUTHENTICATION_ENABLED" : "AuthenticationEnabled",
  "AC_REGISTERED_USERS" : "RegisteredUsers",

  "AUTHZ_WEBSERVICE" : "Authorization.WebService",
  "AUTHZ_TOKEN_HTTP_HEADERS" : "Authorization.TokenHttpHeaders",
  "AUTHZ_TOKEN_GET_ARGUMENTS" : "Authorization.TokenGetArguments",
  "AUTHZ_UNCHECKED_RESOURCES" : "Authorization.UncheckedResources",
  "AUTHZ_UNCHECKED_FOLDERS" : "Authorization.UncheckedFolders",
  "AUTHZ_UNCHECKED_LEVELS" : "Authorization.UncheckedLevels",

  "DW_ROOT" : "DicomWeb.Root",
  "DW_WADO_URI_ENABLED" : "DicomWeb.EnableWado",
  "DW_WADO_URI_ROOT" : "DicomWeb.WadoRoot",
  "DW_HOST" : "DicomWeb.Host",
  "DW_TLS" : "DicomWeb.Ssl",
  "DW_SERVERS" : "DicomWeb.Servers",
  "DW_STOW_MAX_INSTANCES" : "DicomWeb.StowMaxInstances",
  "DW_STOW_MAX_SIZE" : "DicomWeb.StowMaxSize",

  "LUA_OPTIONS" : "LuaOptions",

  "AZSTOR_ACC_NAME": "BlobStorage.AccountName",
  "WL_STORAGE_DIR": "Worklists.Database",

  "WVB_ANNOTATIONS_STORAGE_ENABLED" : "WebViewer.AnnotationStorageEnabled",
  "WVB_COMBINED_TOOL_ENABLED" : "WebViewer.CombinedToolEnabled",
  "WVB_CROSS_HAIR_ENABLED" : "WebViewer.CrossHairEnabled",
  "WVB_LANGUAGE" : "WebViewer.DefaultLanguage",
  "WVB_DEFAULT_SELECTED_TOOL" : "WebViewer.DefaultSelectedTool",
  "WVB_DOWNLOAD_AS_JPEG_ENABLED" : "WebViewer.DownloadAsJpegEnabled",
  "WVB_INSTANCE_INFO_CACHE_ENABLED" : "WebViewer.InstanceInfoCacheEnabled",
  "WVB_KEY_IMAGE_CAPTURE_ENABLED" : "WebViewer.KeyImageCaptureEnabled",
  "WVB_KEYBOARD_SHORTCUTS_ENABLED" : "WebViewer.KeyboardShortcutsEnabled",
  "WVB_OPEN_ALL_PATIENT_STUDIES" : "WebViewer.OpenAllPatientStudies",
  "WVB_PRINT_ENABLED" : "WebViewer.PrintEnabled",
  "WVB_REFERENCE_LINES_ENABLED" : "WebViewer.ReferenceLinesEnabled",
  "WVB_SERIES_TO_IGNORE" : "WebViewer.SeriesToIgnore",
  "WVB_STUDY_DOWNLOAD_ENABLED" : "WebViewer.StudyDownloadEnabled",
  "WVB_SYNCHRONIZED_BROWSING_ENABLED" : "WebViewer.SynchronizedBrowsingEnabled",
  "WVB_TOGGLE_OVERLAY_TEXT_BUTTON_ENABLED" : "WebViewer.ToggleOverlayTextButtonEnabled",
  "WVB_VIDEO_ENABLED" : "WebViewer.VideoDisplayEnabled",

  "WVP_LICENSE_STRING" : "WebViewer.LicenseString",
  "WVP_LIVESHARE_ENABLED" : "WebViewer.LiveshareEnabled",
  "WVP_ANNOTATIONS_STORAGE_ENABLED" : "WebViewer.AnnotationStorageEnabled",
  "WVP_COMBINED_TOOL_ENABLED" : "WebViewer.CombinedToolEnabled",
  "WVP_CROSS_HAIR_ENABLED" : "WebViewer.CrossHairEnabled",
  "WVP_LANGUAGE" : "WebViewer.DefaultLanguage",
  "WVP_DEFAULT_SELECTED_TOOL" : "WebViewer.DefaultSelectedTool",
  "WVP_DOWNLOAD_AS_JPEG_ENABLED" : "WebViewer.DownloadAsJpegEnabled",
  "WVP_INSTANCE_INFO_CACHE_ENABLED" : "WebViewer.InstanceInfoCacheEnabled",
  "WVP_KEY_IMAGE_CAPTURE_ENABLED" : "WebViewer.KeyImageCaptureEnabled",
  "WVP_KEYBOARD_SHORTCUTS_ENABLED" : "WebViewer.KeyboardShortcutsEnabled",
  "WVP_OPEN_ALL_PATIENT_STUDIES" : "WebViewer.OpenAllPatientStudies",
  "WVP_PRINT_ENABLED" : "WebViewer.PrintEnabled",
  "WVP_REFERENCE_LINES_ENABLED" : "WebViewer.ReferenceLinesEnabled",
  "WVP_SERIES_TO_IGNORE" : "WebViewer.SeriesToIgnore",
  "WVP_STUDY_DOWNLOAD_ENABLED" : "WebViewer.StudyDownloadEnabled",
  "WVP_SYNCHRONIZED_BROWSING_ENABLED" : "WebViewer.SynchronizedBrowsingEnabled",
  "WVP_TOGGLE_OVERLAY_TEXT_BUTTON_ENABLED" : "WebViewer.ToggleOverlayTextButtonEnabled",
  "WVP_VIDEO_ENABLED" : "WebViewer.VideoDisplayEnabled",
}

# transforms QUERY_RETRIEVE_SIZE into QueryRetrieveSize
def envVarToCamelCase(envVarName: str) -> str:
  name = ""
  for word in envVarName.split("_"):
    name = name + word[0] + word.lower()[1:]
  return name

def getJsonPathFromEnvVarName(envVarName: str) -> typing.List[str]:
  if envVarName in nonStandardEnvVarNames:
    return nonStandardEnvVarNames[envVarName].split(".")

  envVarTokens = envVarName[len("ORTHANC__"):].split("__")
  path = []
  for envVarToken in envVarTokens:
    path.append(envVarToCamelCase(envVarToken))

  return path


################# read all configuration files ################################
configFiles = []

for filePath in glob.glob("/etc/orthanc/*.json"):
  configFiles.append(filePath)

for filePath in glob.glob("/run/secrets/*.json"):
  configFiles.append(filePath)

for filePath in glob.glob("./docker/orthanc-builder-all/tmp/*.json"):
  configFiles.append(filePath)

for filePath in configFiles:
  logInfo("reading configuration from " + filePath)
  with open(filePath, "r") as f:
    content = f.read()
    cleanedContent = removeCppCommentsFromJson(content)
    configFromFile = json.loads(cleanedContent)
    configurator.mergeConfigFromFile(configFromFile, filePath)

################# read all environment variables ################################

secretsFiles = {}

for envKey, envValue in os.environ.items():
  if envKey.startswith("ORTHANC__") or envKey in nonStandardEnvVarNames:
    if envKey in nonStandardEnvVarNames:
      logWarning("You're using a deprecated environment variable name: " + envKey)

    jsonPath = getJsonPathFromEnvVarName(envKey)
    configurator.setConfig(jsonPath=jsonPath, value=envValue, source="env-var:" + envKey)
  if envKey.endswith("_SECRET"):  # these env var defines the file in which we'll find the value of their env var !
    envVarName = envKey[:len("_SECRET")]
    fileName = os.environ.get(envKey)
    secretsFiles[fileName] = envVarName

################# read all secrets ################################

def readSecret(path: str, envKey: str):
  global configurator
  jsonPath = getJsonPathFromEnvVarName(envKey)
  configurator.setConfig(jsonPath=jsonPath, value=envValue, source="secret:" + envKey)


# parse all files in /run/secrets whose filename looks like an env-variable (i.e ORTHANC__MYSQL__PASSWORD)
envVarLikeName = re.compile("[A-Z\_]*")
legacySecret = re.compile("[A-Z\_]*_SECRET$")

for secretPath in glob.glob("/run/secrets/*"):
  relativeSecretPath = secretPath[len("/run/secrets/"):]
  
  if relativeSecretPath in secretsFiles:
    readSecret(secretPath, secretsFiles[relativeSecretPath])
  
  elif relativeSecretPath.startswith("ORTHANC__") or relativeSecretPath in nonStandardEnvVarNames:
  
    if relativeSecretPath in nonStandardEnvVarNames:
      logWarning("You're using a deprecated secret name: " + relativeSecretPath)

    readSecret(secretPath, relativeSecretPath)

################# apply defaults that have not been set yet ################################

# orthanc defaults
with open(os.path.dirname(os.path.realpath(__file__)) + "/orthanc-defaults.json") as fp:
  orthancNonStandardDefaults = json.load(fp)

configurator.mergeConfigFromDefaults(orthancNonStandardDefaults, "orthanc")


################# enable plugins and apply their defaults ################################

with open(os.path.dirname(os.path.realpath(__file__)) + "/plugins-def.json") as fp:
  plugins = json.load(fp)


for pluginName, pluginDef in plugins.items():
  
  if "section" in pluginDef:
    section = pluginDef["section"]
  else:
    section = pluginName

  enabled = section in configurator.configuration

  # multiple plugins can have the same section (i.e: the web-viewers)
  # so they need to have one of their enabling env var set to true
  if pluginDef["enablingEnvVarIsRequired"]:
    enabled = False
  else:
    # for other plugins, if at least one setting of the plugin section has been defined,
    # it is considered as enabled
    enabled = section in configurator.configuration

  if "enablingEnvVar" in pluginDef and isEnvVarDefinedEmptyOrTrue(pluginDef["enablingEnvVar"]):
    enabled = True
  if "enablingEnvVarLegacy" in pluginDef and isEnvVarDefinedEmptyOrTrue(pluginDef["enablingEnvVarLegacy"]):
    enabled = True
    logWarning("You're using a deprecated env-var to enable the {p} plugin, you should use {n} instead of {o}".format(
      p=pluginName,
      n=pluginDef["enablingEnvVar"],
      o=pluginDef["enablingEnvVarLegacy"]
    ))
    hasDeprecatedSettings = True

  if enabled:
    # copy defaults config and move the plugin.so into the right folder

    logInfo("Enabling {p} plugin".format(p = pluginName))
    
    if "nonStandardDefaults" in plugins[pluginName]:

      pluginDefaultConfig = {
        section: plugins[pluginName]["nonStandardDefaults"]
      }
      configurator.mergeConfigFromDefaults(pluginDefaultConfig, pluginName)
    
    if "libs" in pluginDef:
      for lib in pluginDef["libs"]:
        try:
          os.rename("/usr/share/orthanc/plugins-disabled/" + lib, "/usr/share/orthanc/plugins/" + lib)
        except:
          logError("failed to move {l} file".format(l = lib))
          hasErrors = True
  else:
    logInfo("{p} won't be enabled, no configuration found for this plugin".format(p = pluginName))

logInfo("generated configuration file: " + json.dumps(configurator.configuration, indent=2))

if hasDeprecatedSettings:
  logWarning("************* you are using deprecated settings, these deprecated settings will be removed in June 2021 *************")

if hasErrors:
  logError("There were some errors while preparing Orthanc to start.")
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

