import os
import re
import glob
import json
import typing
import tempfile
import subprocess

from configurator import OrthancConfigurator


colWidths = [50, 50, 100]

def printSeparatorLine(char):
  print("+" + char*colWidths[0] + "+" + char*colWidths[1] + "+" + char*colWidths[2] + "+")

def fixedLengthString(length):
  return "{0:" + str(length) + "}"

def printContentLine(cells):
  i = 0
  outputCells = []
  for cell in cells:
    if cell is None:
      cell = ""
    outputCells.append(fixedLengthString(colWidths[i]-2).format(cell)) # -2 for the 2 white spaces around '|'

    i = i + 1

  print("| " + " | ".join(outputCells) + " |")


configurator = OrthancConfigurator()

table = []

printSeparatorLine("-")
printContentLine(["Plugin", "Environment variable", "Default configuration"])
printSeparatorLine("=")

for pluginName, pluginDef in configurator.pluginsDef.items():
  if "section" in pluginDef:
    section = pluginDef["section"]
  else:
    section = pluginName

  cell0 = ["**" + pluginName + "**"]
  cell1 = ["``" + pluginDef["enablingEnvVar"] + "``"]
  cell2 = [".. code-block:: json", ""] 

  if "enabledByDefault" in pluginDef and pluginDef["enabledByDefault"]:
    cell1.append("Note: enabled by default")

  if "nonStandardDefaults" in pluginDef:
    defaultSettings = {
      section: pluginDef["nonStandardDefaults"]
    }
    jsonString = json.dumps(defaultSettings, indent=2)

    for jsonLine in jsonString.split("\n"):
      cell2.append("  " + jsonLine)

  else:
    cell2 = [""]

  for l in range(max(len(c) for c in [cell0, cell1, cell2])):
    c0 = cell0[l] if l < len(cell0) else ""
    c1 = cell1[l] if l < len(cell1) else ""
    c2 = cell2[l] if l < len(cell2) else ""

    printContentLine([c0, c1, c2])

  printSeparatorLine("-")

