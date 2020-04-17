import os
import re
import glob
import json
import typing

from helpers import JsonPath, logInfo, logWarning, logError, removeCppCommentsFromJson, isEnvVarDefinedEmptyOrTrue, enableVerboseModeForConfigGeneration, envVarToCamelCase, insertInDict


class OrthancConfigurator:

  def __init__(self):
    self.configurationSource = {}
    self.configuration = {}
    self.enabledPlugins = []

    self.hasErrors = False
    self.hasDeprecatedSettings = False

    self.nonStandardEnvVarNames = {}
    self.orthancNonStandardDefaults = {}
    self.pluginsDef = {}
    self.secretsFiles = {}
    self.pluginsEnabledByEnvVar = set()

    self.loadSettings()


  def getEnabledPlugins(self) -> typing.List[str]:

    enabledPlugins = []

    for pluginName, pluginDef in self.pluginsDef.items():

      if "section" in pluginDef:
        section = pluginDef["section"]
      else:
        section = pluginName

      # multiple plugins can have the same section (i.e: the web-viewers)
      # so they need to have one of their enabling env var set to true
      if "enablingEnvVarIsRequired" in pluginDef and pluginDef["enablingEnvVarIsRequired"]:
        enabled = pluginName in self.pluginsEnabledByEnvVar
      else:
        # for other plugins, if at least one setting of the plugin section has been defined,
        # it is considered as enabled
        enabled = (section in self.configuration) or (pluginName in self.pluginsEnabledByEnvVar)

      if enabled:
        enabledPlugins.append(pluginName)

    return enabledPlugins


  def loadSettings(self):

    # load non standard env-vars
    with open(os.path.dirname(os.path.realpath(__file__)) + "/env-var-legacy.json") as fp:
      self.nonStandardEnvVarNames = json.load(fp)

    # orthanc variables not following the standard conversion rule
    with open(os.path.dirname(os.path.realpath(__file__)) + "/env-var-non-standards.json") as fp:
      self.nonStandardEnvVarNames.update(json.load(fp))

    # orthanc defaults
    with open(os.path.dirname(os.path.realpath(__file__)) + "/orthanc-defaults.json") as fp:
      self.orthancNonStandardDefaults = json.load(fp)

    # plugins def
    with open(os.path.dirname(os.path.realpath(__file__)) + "/plugins-def.json") as fp:
      self.pluginsDef = json.load(fp)

  def getJsonPathFromEnvVarName(self, envVarName: str) -> JsonPath:
    if envVarName in self.nonStandardEnvVarNames:
      return JsonPath(self.nonStandardEnvVarNames[envVarName])

    elif envVarName.startswith("ORTHANC__"):
      envVarTokens = envVarName[len("ORTHANC__"):].split("__")
      jsonPath = JsonPath()
      for envVarToken in envVarTokens:
        jsonPath.append(envVarToCamelCase(envVarToken))

      return jsonPath

    raise ValueError("unhandled env-var name: " + envVarName)


  def _mergeConfigs(self, first: dict, second: dict, secondSource: str, jsonPath: JsonPath, overwrite: bool) -> dict:
    
    apply = True
    for k, v in second.items():
      keyPath = jsonPath.clone()
      keyPath.append(k)

      if isinstance(v, dict) and k in first:
        self._mergeConfigs(first[k], second[k], secondSource, keyPath, overwrite)
        apply = False
      elif k in first and str(keyPath) in self.configurationSource:
        if overwrite:
          logWarning("{k} has already been defined in {cs}; it will be overwritten by the value defined in {s}".format(k = str(keyPath), cs = self.configurationSource[str(keyPath)], s = secondSource))
        else:
          apply = False

      if apply:
        self.configurationSource[str(keyPath)] = secondSource
        first[k] = v
    
    return first

  def mergeConfigFromFile(self, config: dict, configFilePath: str):
    self.configuration = self._mergeConfigs(first=self.configuration, second=config, secondSource="file:" + configFilePath, jsonPath=JsonPath(), overwrite=True)

  def _mergeConfigFromDefaults(self, config: dict, defaultsGroup: str):
    self.configuration = self._mergeConfigs(first=self.configuration, second=config, secondSource="defaults:" + defaultsGroup, jsonPath=JsonPath(), overwrite=False)

  def mergeConfigFromDefaults(self, moveSoFiles: bool):
    
    self._mergeConfigFromDefaults(self.orthancNonStandardDefaults, "orthanc")

    for pluginName in self.getEnabledPlugins():
      
      pluginDef = self.pluginsDef[pluginName]

      if "section" in pluginDef:
        section = pluginDef["section"]
      else:
        section = pluginName
      
      if "nonStandardDefaults" in pluginDef:

        logInfo("Applying defaults for {p} plugin".format(p = pluginName))

        pluginDefaultConfig = {
          section: pluginDef["nonStandardDefaults"]
        }
        self._mergeConfigFromDefaults(pluginDefaultConfig, pluginName)

      if "libs" in pluginDef:
        for lib in pluginDef["libs"]:
          try:
            os.rename("/usr/share/orthanc/plugins-disabled/" + lib, "/usr/share/orthanc/plugins/" + lib)
          except:
            logError("failed to move {l} file".format(l = lib))
            self.hasErrors = True


  def mergeConfigFromEnvVar(self, envKey: str, envValue:str):
  
    if envKey.endswith("_SECRET"):  # these env var defines the file in which we'll find the value of their env var !
      envVarName = envKey[:-len("_SECRET")]
      fileName = os.environ.get(envKey)
      logInfo("secret-key-file: " + envVarName + " / " + fileName)
      self.secretsFiles[fileName] = envVarName

    elif envKey.startswith("ORTHANC__") or envKey in self.nonStandardEnvVarNames:

      if envKey in self.nonStandardEnvVarNames:
        logWarning("You're using a deprecated environment variable name: " + envKey)

      jsonPath = self.getJsonPathFromEnvVarName(envKey)
      self.setConfig(jsonPath=jsonPath, value=envValue, source="env-var:" + envKey)

    else:
      # check if the env var is one that is enabling a plugin
      for pluginName, pluginDef in self.pluginsDef.items():
        if "enablingEnvVar" in pluginDef and pluginDef["enablingEnvVar"] == envKey and envValue != "false":
          self.pluginsEnabledByEnvVar.add(pluginName)
        
        if "enablingEnvVarLegacy" in pluginDef and pluginDef["enablingEnvVarLegacy"] == envKey and envValue != "false":
          self.pluginsEnabledByEnvVar.add(pluginName)
          logWarning("You're using a deprecated env-var to enable the {p} plugin, you should use {n} instead of {o}".format(
            p=pluginName,
            n=pluginDef["enablingEnvVar"],
            o=pluginDef["enablingEnvVarLegacy"]
          ))
          self.hasDeprecatedSettings = True


  def mergeConfigFromSecret(self, secretPath: str, content: str):
    relativeSecretPath = secretPath[len("/run/secrets/"):]
  
    # this is one secret file that has been defined in i.e ORTHANC__POSTGRESQL_PASSWORD_SECRET env-var
    # that defines the file in which ORTHANC__POSTRESQL_PASSWORD will be stored
    if relativeSecretPath in self.secretsFiles:
      readSecret(secretPath, content, self.secretsFiles[relativeSecretPath])
    
    # else this is a secret whose name is i.e ORTHANC__POSTRESQL_PASSWORD
    elif relativeSecretPath.startswith("ORTHANC__") or relativeSecretPath in nonStandardEnvVarNames:
    
      if relativeSecretPath in nonStandardEnvVarNames:
        logWarning("You're using a deprecated secret name: " + relativeSecretPath)

      readSecret(secretPath, content, relativeSecretPath)


  def readSecret(self, path: str, content: str, envKey: str):

    try:
      jsonPath = self.getJsonPathFromEnvVarName(envKey)
    except ValueError as e:
      logInfo("secret won't be read: " + envKey)
      return
    
    logInfo("readSecret: from {s} into {e} will go into json {j}".format(s=path, e=envKey, j=jsonPath))
    self.setConfig(jsonPath=jsonPath, value=content, source="secret:" + envKey)


  def setConfig(self, jsonPath: JsonPath, value: str, source: str, overwrite: bool = True):
    try:
      jsonValue = json.loads(value) # will work for number, booleans and json but not for strings
    except ValueError as e:
      jsonValue = value

    configFromEnvVar = insertInDict(jsonPath, jsonValue)
    return self._mergeConfigs(first=self.configuration, second=configFromEnvVar, secondSource=source, jsonPath=JsonPath(), overwrite=overwrite)

  # def setDefault(self, path: str, value: any):
  #   jsonPath = path.split(".")

  #   configFromDefault = insertInDict(jsonPath, value)
  #   return self._mergeConfigs(first=self.configuration, second=configFromDefault, secondSource="defaults", jsonPath=jsonPath, overwrite=False)
