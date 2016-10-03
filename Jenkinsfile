stage 'Build & test across platforms'

lock('orthanc-builder-workspace') {
    def workspacePath = '../_orthanc-ws' // we need a short workspace name to avoid long path issues with boost lib

	stage('Checkout SCM osx') {
		node('osx') { dir(path: workspacePath) {
			checkout scm
		}}
	}
	stage('Checkout SCM win') {
		node('windows') { dir(path: workspacePath) {
			checkout scm
		}}
	}

	def buildMap = [:] //we'll trigger all stages in parallel so the failure of one of the stage will not stop the complete job

	buildMap.put('osx-orthanc', {
		stage('Build orthanc for osx') {
			node('osx') { dir(path: workspacePath) {
				sh './ciBuildOrthancOSX.sh build --orthanc nightly'
				lock('orthanc-publisher-osx') { //regenerate the package after each build
					withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-orthanc.osimis.io']]) {
						sh './ciBuildOrthancOSX.sh publish nightly'  
					}
				}
			}}
		}
	})

	buildMap.put('osx-dicomweb', {
		stage('Build dicomweb for osx') {
			node('osx') { dir(path: workspacePath) {
				sh './ciBuildOrthancOSX.sh build --dicomweb nightly'
				lock('orthanc-publisher-osx') { //regenerate the package after each build
					withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-orthanc.osimis.io']]) {
						sh './ciBuildOrthancOSX.sh publish nightly'  
					}
				}
			}}
		}
	})

	buildMap.put('win-orthanc', {
		stage('Build orthanc for windows') {
			node('windows') { dir(path: workspacePath) {
				bat 'powershell.exe ./ciBuildOrthancWin.ps1 build --orthanc nightly'
				lock('orthanc-publisher-win') { //regenerate the package after each build
					withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-orthanc.osimis.io']]) {
						bat 'powershell.exe ./ciBuildOrthancWin.ps1 publish nightly' 
					}
				}
			}}
		}
	})

	buildMap.put('win-dicomweb', {
		stage('Build dicomweb for windows') {
			node('windows') { dir(path: workspacePath) {
				bat 'powershell.exe ./ciBuildOrthancWin.ps1 build --dicomweb nightly'
				lock('orthanc-publisher-win') { //regenerate the package after each build
					withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-orthanc.osimis.io']]) {
						bat 'powershell.exe ./ciBuildOrthancWin.ps1 publish nightly' 
					}
				}
			}}
		}
	})

	parallel(buildMap)
}
