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


# transforms QUERY_RETRIEVE_SIZE into QueryRetrieveSize
def envVarToCamelCase(envVarName: str) -> str:
  name = ""
  for word in envVarName.split("_"):
    name = name + word[0] + word.lower()[1:]
  return name


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


