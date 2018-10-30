#!/bin/bash
# prerequisites: sudo apt-get install -y python3 python3-venv
# create a Python Virtual Environment and adds the current path to the python path
# eventually, adds another path (passed in argument)
#
set -x #to debug the script

#remove previous environment
rm -rf env/
set -e #to stop script execution at the first failure
#create a python virtual environment in the current dir
pyvenv env
pythonVersion=$(python3 --version)
if [[ $pythonVersion == *"3.4"* ]]; then
  echo "using python version 3.4 ($pythonVersion)"
  pathToPythonPath=env/lib/python3.4/site-packages/path.pth
elif [[ $pythonVersion == *"3.5"* ]]; then
  echo "using python version 3.5 ($pythonVersion)"
  pathToPythonPath=env/lib/python3.5/site-packages/path.pth
elif [[ $pythonVersion == *"3.6"* ]]; then
  echo "using python version 3.6 ($pythonVersion)"
  pathToPythonPath=env/lib/python3.6/site-packages/path.pth
else
  echo "update createPythonVenv.sh to support your python version"
  exit 1
fi

#add the current dir to the python path (the path where we started the script from .. you should start it from the pythonToolbox directory, not the script directory)
echo $(pwd) > $pathToPythonPath

#if another script was passed in argument, add it to the python path too
if [ ! -z $1 ]; then
  echo $1 | tee -a $pathToPythonPath       #note: OSX does not support --append but only -a
fi