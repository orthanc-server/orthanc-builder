stage 'Build & test across platforms'
parallel 
	osx: {
		node('osx') {
			checkout scm
			sh './ciBuildOrthancOSX.sh build --orthanc nightly'
			sh './ciBuildOrthancOSX.sh publish nightly'  // after each successful build, we regenerate the package
		}
	},
	windows: {
		node('windows') {
			checkout scm
   			bat 'powershell.exe ./ciBuildOrthancWin.ps1 build --orthanc nightly'
   			bat 'powershell.exe ./ciBuildOrthancWin.ps1 publish nightly' // after each successful build, we regenerate the package
		}
	}
