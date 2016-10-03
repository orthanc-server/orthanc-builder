stage 'Build & test across platforms'

lock('orthanc-builder-workspace') {
    def rootWorkspacePath = '../_ws' // we need a short workspace name to avoid long path issues with boost lib

	def buildMap = [:] //we'll trigger all stages in parallel so the failure of one of the stage will not stop the complete job

	buildMap.put('osx-orthanc', {
		stage('Build orthanc for osx') {
			node('osx') { dir(path: rootWorkspacePath + '-orthanc') {
				checkout scm
				lock('orthanc-builder-osx') { 
					sh './ciBuildOrthancOSX.sh build --orthanc nightly'
					
					//regenerate the package after each build
					sh './ciBuildOrthancOSX.sh publish nightly'  
				}
			}}
		}
	})

	buildMap.put('osx-dicomweb', {
		stage('Build dicomweb for osx') {
			node('osx') { dir(path: rootWorkspacePath + '-dicomweb') {
				checkout scm
				lock('orthanc-builder-osx') { 
					sh './ciBuildOrthancOSX.sh build --dicomweb nightly'

					//regenerate the package after each build
					sh './ciBuildOrthancOSX.sh publish nightly'  
				}
			}}
		}
	})

	buildMap.put('win-orthanc', {
		stage('Build orthanc for windows') {
			node('windows') { dir(path: rootWorkspacePath + '-orthanc') {
				checkout scm
				lock('orthanc-builder-win') { 
					bat 'powershell.exe ./ciBuildOrthancWin.ps1 build --orthanc nightly'
				
					//regenerate the package after each build
					bat 'powershell.exe ./ciBuildOrthancWin.ps1 publish nightly' 
				}
			}}
		}
	})

	buildMap.put('win-dicomweb', {
		stage('Build dicomweb for windows') {
			node('windows') { dir(path: rootWorkspacePath + '-dicomweb') {
				checkout scm
				lock('orthanc-builder-win') { 
					bat 'powershell.exe ./ciBuildOrthancWin.ps1 build --dicomweb nightly'
				
					//regenerate the package after each build
					bat 'powershell.exe ./ciBuildOrthancWin.ps1 publish nightly' 
				}
			}}
		}
	})

	withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-orthanc.osimis.io']]) {
		parallel(buildMap)
	}
}
