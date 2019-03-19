param(
     [Parameter(Position=0)][string]$stableOrNightly= "nightly"
)

# create a virtual env at the root of pythonToolbox.git
python -m venv env
env\Scripts\activate.ps1
$env:PYTHONPATH=$(pwd);$env:PYTHONPATH
pip install -r requirements.txt
pip install --upgrade boto3
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE}


python buildOrthancZipPackage.py $stableOrNightly --config WindowsInstaller\Orthanc-32.json --clearBefore
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE}

python buildOrthancZipPackage.py $stableOrNightly --config WindowsInstaller\Orthanc-64.json --clearBefore
f ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE}
