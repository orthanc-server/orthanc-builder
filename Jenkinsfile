stage 'Build & test across platforms'
	windows: {
		node('windows') {
			checkout scm
   			bat 'powershell.exe ./ciBuildOrthancWin.ps1 build --orthanc nightly'
   			bat 'powershell.exe ./ciBuildOrthancWin.ps1 publish nightly'
		}
	}
