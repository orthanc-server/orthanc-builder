import os
import re
import glob
import json
import typing

from helpers import OrthancConfigurator, logInfo, logWarning, logError, removeCppCommentsFromJson

os.environ["ORTHANC__QUERY_RETRIEVE_SIZE"] = "1"
os.environ["ORTHANC__DICOM_AET"] = "ORTHANC_ENV"
os.environ["ORTHANC__CASE_SENSITIVE_PN"] = "false"
os.environ["ORTHANC__PKCS11__MODULE"] = "tutu"
os.environ["AZSTOR_ACC_NAME"] = "tito"
os.environ["WL_ENABLED"] = "true"
os.environ["WVB_ALPHA_ENABLED"] = "true"
os.environ["ORTHANC__WEB_VIEWER__CACHE_ENABLED"] = "true"

errors = False
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

  "LUA_OPTIONS" : "LuaOptions",

  "AZSTOR_ACC_NAME": "BlobStorage.AccountName",
  "WL_STORAGE_DIR": "Worklists.Database",
  "WL_ENABLED": "Worklists.Enable",

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

for envKey, envValue in os.environ.items():
  if envKey.startswith("ORTHANC__") or envKey in nonStandardEnvVarNames:
    jsonPath = getJsonPathFromEnvVarName(envKey)
    configurator.setConfig(jsonPath=jsonPath, value=envValue, source="env-var:" + envKey)

################# read all secrets ################################

# TODO:
# parse all files in /run/secrets whose filename looks like an env-variable (i.e MYSQL_PASSWORD)
# skip the var whose name is in legacySecretsEnvVars
# read its content and consider it's the value of the env-var

################# read all secrets (backward-compatibility) ################################

legacySecretsEnvVars = {
  "MYSQL_PASSWORD_SECRET" : "MYSQL_PASSWORD"
}

# TODO:
# get value of each of these legacySecretsEnvVars
# if found, read the file in /run/secrets/ and consider it's the value of the env-var

################# apply defaults that have not been set yet ################################

orthancNonStandardDefaults = {
  "StorageDirectory" : "/var/lib/orthanc/db",
  "IndexDirectory" : "/var/lib/orthanc/db",

  "RemoteAccessAllowed": True,
  "AuthenticationEnabled": True,


  "Plugins" : ["/usr/share/orthanc/plugins/"]
}

plugins = {
  "Worklists" : {
    "nonStandardDefaults" : {
      "Enable" : True,
      "Database" : "/var/lib/orthanc/worklists"
    },
    "libs" : ["libModalityWorklists.so"]
  },
  "OrthancWebViewer" : {
    "section" : "WebViewer",
    "enablingEnvVars" : ["OWV_ENABLED", "ORTHANC_VIEWER_ENABLED"],  # only for plugins who share a section with other plugins !
    "libs" : ["libOrthancWebViewer.so"],

  },
  "OsimisWebViewerBasic" : {
    "section" : "WebViewer",
    "enablingEnvVars" : ["WVB_ENABLED", "OSIMIS_VIEWER_ENABLED"],  # only for plugins who share a section with other plugins !
    "libs" : ["libOsimisWebViewer.so"]
  },
  "OsimisWebViewerBasicAlpha" : {
    "section" : "WebViewer",
    "enablingEnvVars" : ["WVB_ALPHA_ENABLED", "OSIMIS_VIEWER_ALPHA_ENABLED"],  # only for plugins who share a section with other plugins !
    "libs" : ["libOsimisWebViewerAlpha.so"]
  }
}

configurator.mergeConfigFromDefaults(orthancNonStandardDefaults, "orthanc")

for pluginName, pluginDef in plugins.items():
  
  if "section" in pluginDef:
    section = pluginDef["section"]
  else:
    section = pluginName

  # if at least one setting of the plugin section has been defined, apply the plugin defaults
  # and copy the plugin in the right directory
  enabled = section in configurator.configuration

  # however, multiple plugins can have the same section (i.e: the web-viewers)
  # so they need to have one of their enabling env var set to true
  if "enablingEnvVars" in pluginDef:
    enabled = False
    for envVar in pluginDef["enablingEnvVars"]:
      if os.environ.get(envVar, "false") == "true":
        enabled = True

  if enabled:

    logInfo("Enabling {p} plugin".format(p = pluginName))
    
    if "nonStandardDefaults" in plugins[pluginName]:
      configurator.mergeConfigFromDefaults(plugins[pluginName]["nonStandardDefaults"], section)
    
    if "libs" in pluginDef:
      for lib in pluginDef["libs"]:
        try:
          os.rename("/usr/share/orthanc/plugins-disabled/" + lib, "/usr/share/orthanc/plugins/" + lib)
        except:
          logError("failed to move {l} file".format(l = lib))
          errors = True
  else:
    logInfo("{p} won't be enabled, no configuration found for this plugin".format(p = pluginName))

print(json.dumps(configurator.configuration, indent=2))

if not errors:
  # launch Orthanc
  pass
else:
  logError("There were some errors while preparing Orthanc to start.")
