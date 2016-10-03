stage 'Build & test across platforms'

def buildMap = [:]

buildMap.put('osx', {
	stage('Build orthanc for osx') {
		node('osx') {
			checkout scm
			sh './ciBuildOrthancOSX.sh build --orthanc nightly'
			sh './ciBuildOrthancOSX.sh publish nightly'  // after each successful build, we regenerate the package
		}
	}
})

buildMap.put('windows', {
	stage('Build orthanc for windows') {
		node('windows') {
			checkout scm
   			bat 'powershell.exe ./ciBuildOrthancWin.ps1 build --orthanc nightly'
   			bat 'powershell.exe ./ciBuildOrthancWin.ps1 publish nightly' // after each successful build, we regenerate the package
		}
	}
})

parallel(buildMap)