import os
import re
import glob
import json
import typing


def logInfo(text: str):
  print(text)

def logWarning(text: str):
  print("WARNING: " + text)

def logError(text: str):
  print("ERROR: " + text)

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

def insertInDict(jsonPath: typing.List[str], value: any) -> dict:
  if len(jsonPath) == 1:
    output = {}
    output[jsonPath[0]] = value
    return output
  else:
    output = {}
    output[jsonPath[0]] = insertInDict(jsonPath[1:], value)
    return output


class OrthancConfigurator:

  def __init__(self):
    self.configurationSource = {}
    self.configuration = {}

  def _mergeConfigs(self, first: dict, second: dict, secondSource: str, jsonPath: typing.List[str], overwrite: bool) -> dict:
    
    apply = True
    for k, v in second.items():
      keyPath = ".".join(jsonPath + [k])
      if isinstance(v, dict) and k in first:
        self._mergeConfigs(first[k], second[k], secondSource, jsonPath + [k], overwrite)
      elif k in first and keyPath in self.configurationSource:
        if overwrite:
          logWarning("{k} has already been defined in {cs}; it will be overwritten by the value defined in {s}".format(k = keyPath, cs = self.configurationSource[keyPath], s = secondSource))
        else:
          apply = False

      if apply:
        self.configurationSource[keyPath] = secondSource
        first[k] = v
    
    return first

  def mergeConfigFromFile(self, config: dict, configFilePath: str):
    self.configuration = self._mergeConfigs(first=self.configuration, second=config, secondSource="file:" + configFilePath, jsonPath=[], overwrite=True)

  def mergeConfigFromDefaults(self, config: dict, defaultsGroup: str):
    self.configuration = self._mergeConfigs(first=self.configuration, second=config, secondSource="defaults:" + defaultsGroup, jsonPath=[], overwrite=False)

  def setConfig(self, jsonPath: typing.List[str], value: str, source: str, overwrite: bool = True):
    try:
      jsonValue = json.loads(value) # will work for number, booleans and json but not for strings
    except ValueError as e:
      jsonValue = value

    configFromEnvVar = insertInDict(jsonPath, jsonValue)
    return self._mergeConfigs(first=self.configuration, second=configFromEnvVar, secondSource=source, jsonPath=jsonPath[1:], overwrite=overwrite)

  # def setDefault(self, path: str, value: any):
  #   jsonPath = path.split(".")

  #   configFromDefault = insertInDict(jsonPath, value)
  #   return self._mergeConfigs(first=self.configuration, second=configFromDefault, secondSource="defaults", jsonPath=jsonPath, overwrite=False)
