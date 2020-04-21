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

  cell0 = "**" + pluginName + "**"
  cell1 = "``" + pluginDef["enablingEnvVar"] + "``"
  cell3 = [".. code-block:: json", ""] 


  if "nonStandardDefaults" in pluginDef:
    defaultSettings = {
      section: pluginDef["nonStandardDefaults"]
    }
    jsonString = json.dumps(defaultSettings, indent=2)

    for jsonLine in jsonString.split("\n"):
      cell3.append("  " + jsonLine)

  else:
    cell3 = [""]

  for l3 in cell3:
    printContentLine([cell0, cell1, l3])
    cell0 = ""
    cell1 = ""

  printSeparatorLine("-")

