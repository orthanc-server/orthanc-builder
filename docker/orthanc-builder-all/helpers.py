import os
import re
import glob
import json
import typing


class JsonPath:

  def __init__(self, path:str = None):
    if path is None or len(path) == 0:
      self.tokens = []
    else:
      self.tokens = path.split(".")

  def first(self):
    if self.length() == 0:
      raise ValueError("Empty path")

    return self.tokens[0]

  def nexts(self, fromIndex=1):
    if self.length() < fromIndex:
      raise ValueError("Path too short")
    
    return JsonPath(".".join(self.tokens[fromIndex:]))

  def pop(self) -> str:
    if self.length() == 0:
      raise ValueError("Empty path")

    first = self.tokens[0]
    self.tokens = self.tokens[1:]
    return first

  def append(self, token: str):
    self.tokens.append(token)

  def length(self):
    return len(self.tokens)

  def __str__(self):
    return ".".join(self.tokens)

  def clone(self):
    return JsonPath(".".join(self.tokens))


verboseEnabled = False

def enableVerboseModeForConfigGeneration():
  global verboseEnabled
  verboseEnabled = True

def logInfo(text: str):
  global verboseEnabled
  if verboseEnabled:
    print(text)

def logWarning(text: str):
  print("WARNING: " + text)

def logError(text: str):
  print("ERROR: " + text)


def isEnvVarDefinedEmptyOrTrue(envVar: str) -> bool:
  return envVar in os.environ and (os.environ.get(envVar) == "" or os.environ.get(envVar) == "true")

def isEnvVarTrue(envVar: str) -> bool:
  return os.environ.get(envVar, "false") == "true"



def removeCppCommentsFromJson(text: str):
    def replacer(match):
        s = match.group(0)
        if s.startswith('/'):
            return " " # note: a space and not an empty string
        else:
            return s
    pattern = re.compile(
        r'//.*?$|/\*.*?\*/|\'(?:\\.|[^\\\'])*\'|"(?:\\.|[^\\"])*"',
        re.DOTALL | re.MULTILINE
    )
    return re.sub(pattern, replacer, text)

def insertInDict(jsonPath: JsonPath, value: any) -> dict:
  
  if jsonPath.length() == 1:
    output = {}
    output[jsonPath.first()] = value
    return output
  else:
    output = {}
    output[jsonPath.first()] = insertInDict(jsonPath.nexts(1), value)
    return output


class OrthancConfigurator:

  def __init__(self):
    self.configurationSource = {}
    self.configuration = {}

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

  def mergeConfigFromDefaults(self, config: dict, defaultsGroup: str):
    self.configuration = self._mergeConfigs(first=self.configuration, second=config, secondSource="defaults:" + defaultsGroup, jsonPath=JsonPath(), overwrite=False)

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
