#!/bin/bash
# args: build --projectName nightly/stable
#       publish nighlty/stable
# prerequisites: sudo apt-get install -y python3-venv
set -x #to debug the script
set -e #to exit the script at the first failure

action=$1
arg2=$2
arg3=${3:-}

startScriptDir=$(pwd)
export PATH=$PATH:/usr/local/bin   #such that pyvenv works

#create a python virtual environment
source createPythonVenv.sh
source env/bin/activate
pip install -r requirements.txt

#display all SDKs supports by this version of xcode
xcodebuild -showsdks

cd $startScriptDir/
python3 buildOrthancAndPlugins.py $action $arg2 $arg3

cd $startScriptDir
deactivate
