param(
     [Parameter(Position=0)][string]$action = "build",
     [Parameter(Position=1)][string]$arg1 = "--orthanc",
     [Parameter(Position=2)][string]$arg2= "nightly"
)

# create a virtual env at the root of pythonToolbox.git
python -m venv env
env\Scripts\activate.ps1
$env:PYTHONPATH=$(pwd);$env:PYTHONPATH
pip install http://orthanc.osimis.io/pythonToolbox/OsimisToolbox-1.12.3.tar.gz awscli
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE}


if ($action -eq "build") {
    python buildOrthancAndPlugins.py build $arg1 --archi=win64 --vsVersion=2015 $arg2
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE}

    python buildOrthancAndPlugins.py build $arg1 --archi=win32 --vsVersion=2015 --skipCheckout $arg2
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE}
} else {
    python buildOrthancAndPlugins.py publish --archi=win64 $arg1
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE}

    python buildOrthancAndPlugins.py publish --archi=win32 $arg1
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE}
}
deactivate
