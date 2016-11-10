def userInput = [
    buildDicomWebOSX: true,
    buildDicomWebWin: true,
    buildOrthancOSX: true,
    buildOrthancWin: true,
    isStableBuild: false,
    isPackagingOnly: false
];

stage('User inputs') {

	echo 'Let the user choose what he wants to build...'

	// Let user override default settings (max 30 seconds to do so)
	try {
	    timeout(time: 30, unit: 'SECONDS') {
	        userInput = input(
	            id: 'userInput', message: 'Configure build', parameters: [
	                [$class: 'BooleanParameterDefinition', defaultValue: userInput['buildDicomWebOSX'], description: 'Build Dicom Web OSX', name: 'buildDicomWebOSX'],
	                [$class: 'BooleanParameterDefinition', defaultValue: userInput['buildDicomWebWin'], description: 'Build Dicom Web Win', name: 'buildDicomWebWin'],
	                [$class: 'BooleanParameterDefinition', defaultValue: userInput['buildPostgresOSX'], description: 'Build Postgres OSX', name: 'buildPostgresOSX'],
	                [$class: 'BooleanParameterDefinition', defaultValue: userInput['buildPostgresWin'], description: 'Build Postgres Win', name: 'buildPostgresWin'],
	                [$class: 'BooleanParameterDefinition', defaultValue: userInput['buildOrthancOSX'], description: 'Build Orthanc OSX', name: 'buildOrthancOSX'],
	                [$class: 'BooleanParameterDefinition', defaultValue: userInput['buildOrthancWin'], description: 'Build Orthanc Win', name: 'buildOrthancWin'],
	                [$class: 'BooleanParameterDefinition', defaultValue: userInput['isStableBuild'], description: 'Build Stable version instead of nightly', name: 'isStableBuild'],
	                [$class: 'BooleanParameterDefinition', defaultValue: userInput['isPackagingOnly'], description: 'Just make the package, skip compilation', name: 'isPackagingOnly']
	            ]
	        )
	    }
	} catch (err) {
	    // Do nothing, keep default settings (since user has not answered)
	    echo "User personal branch: user either has aborted or hasn't chosen the build settings within the 30 seconds delay..."
	}

	if (userInput['isPackagingOnly']) {
		userInput['buildDicomWebOSX'] = false
		userInput['buildDicomWebWin'] = false
		userInput['buildPostgresOSX'] = false
		userInput['buildPostgresWin'] = false
		userInput['buildOrthancOSX'] = false
		userInput['buildOrthancWin'] = false
	}

	if (userInput['isStableBuild']) {
		buildType = 'stable'
	} else {
		buildType = 'nightly'
	}

	// Print the build parameters
	echo 'Build DicomWeb OSX : ' + (userInput['buildDicomWebOSX'] ? 'yes' : 'no')
	echo 'Build DicomWeb Win : ' + (userInput['buildDicomWebWin'] ? 'yes' : 'no')
	echo 'Build Postgres OSX : ' + (userInput['buildPostgresOSX'] ? 'yes' : 'no')
	echo 'Build Postgres Win : ' + (userInput['buildPostgresWin'] ? 'yes' : 'no')
	echo 'Build Orthanc OSX  : ' + (userInput['buildOrthancOSX'] ? 'yes' : 'no')
	echo 'Build Orthanc Win  : ' + (userInput['buildOrthancWin'] ? 'yes' : 'no')
	echo 'buildType          : ' + buildType
	echo 'isPackagingOnly    : ' + (userInput['isPackagingOnly'] ? 'yes' : 'no')
}

stage('Build & test across platforms') { lock('orthanc-builder-workspace') {
	
    def rootWorkspacePath = '../_ws' // we need a short workspace name to avoid long path issues with boost lib

	def buildMap = [:] // we'll trigger all stages in parallel so the failure of one of the stage will not stop the complete job

	if (userInput['buildOrthancOSX']) {
		buildMap.put('osx-orthanc', {
			stage('Build orthanc for osx') {
				node('osx') { dir(path: rootWorkspacePath + '-orthanc') {
					checkout scm
					lock('orthanc-builder-osx') { 
						withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-orthanc.osimis.io']]) {
							sh './ciBuildOrthancOSX.sh build --orthanc ' + buildType
						
							//regenerate the package after each build
							sh './ciBuildOrthancOSX.sh publish ' + buildType
						}
					}
				}}
			}
		})
	}

	if (userInput['buildDicomWebOSX']) {
		buildMap.put('osx-dicomweb', {
			stage('Build dicomweb for osx') {
				node('osx') { dir(path: rootWorkspacePath + '-dicomweb') {
					checkout scm
					lock('orthanc-builder-osx') { 
						withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-orthanc.osimis.io']]) {
							sh './ciBuildOrthancOSX.sh build --dicomweb ' + buildType

							//regenerate the package after each build
							sh './ciBuildOrthancOSX.sh publish ' + buildType
						}
					}
				}}
			}
		})
	}

	if (userInput['buildPostgresOSX']) {
		buildMap.put('osx-postgres', {
			stage('Build postgres for osx') {
				node('osx') { dir(path: rootWorkspacePath + '-postgres') {
					checkout scm
					lock('orthanc-builder-osx') { 
						withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-orthanc.osimis.io']]) {
							sh './ciBuildOrthancOSX.sh build --postgresql ' + buildType

							//regenerate the package after each build
							sh './ciBuildOrthancOSX.sh publish ' + buildType
						}
					}
				}}
			}
		})
	}

	if (userInput['buildOrthancWin']) {
		buildMap.put('win-orthanc', {
			stage('Build orthanc for windows') {
				node('windows') { dir(path: rootWorkspacePath + '-orthanc') {
					checkout scm
					lock('orthanc-builder-win') { 
						withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-orthanc.osimis.io']]) {
							bat 'powershell.exe ./ciBuildOrthancWin.ps1 build --orthanc ' + buildType
					
							//regenerate the package after each build
							bat 'powershell.exe ./ciBuildOrthancWin.ps1 publish ' + buildType
						}
					}
				}}
			}
		})
	}

	if (userInput['buildDicomWebWin']) {
		buildMap.put('win-dicomweb', {
			stage('Build dicomweb for windows') {
				node('windows') { dir(path: rootWorkspacePath + '-dicomweb') {
					checkout scm

					lock('orthanc-builder-win') { 
						withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-orthanc.osimis.io']]) {
							bat 'powershell.exe ./ciBuildOrthancWin.ps1 build --dicomweb ' + buildType
						
							//regenerate the package after each build
							bat 'powershell.exe ./ciBuildOrthancWin.ps1 publish ' + buildType
						}
					}
				}}
			}
		})
	}

	if (userInput['buildPostgresWin']) {
		buildMap.put('win-postgres', {
			stage('Build postgres for windows') {
				node('windows') { dir(path: rootWorkspacePath + '-postgres') {
					checkout scm

					lock('orthanc-builder-win') { 
						withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-orthanc.osimis.io']]) {
							bat 'powershell.exe ./ciBuildOrthancWin.ps1 build --postgresql ' + buildType
						
							//regenerate the package after each build
							bat 'powershell.exe ./ciBuildOrthancWin.ps1 publish ' + buildType
						}
					}
				}}
			}
		})
	}

	if (userInput['isPackagingOnly']) {
		buildMap.put('packaging osx', {
			stage('Build package for osx') {
				node('osx') { dir(path: rootWorkspacePath + '-packaging') {
					checkout scm

					lock('orthanc-builder-osx') { 
						withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-orthanc.osimis.io']]) {
							sh './ciBuildOrthancOSX.sh publish ' + buildType
						}
					}
				}}
			}
		})
		buildMap.put('packaging win', {
			stage('Build package for windows') {
				node('windows') { dir(path: rootWorkspacePath + '-packaging') {
					checkout scm

					lock('orthanc-builder-win') { 
						withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-orthanc.osimis.io']]) {
							bat 'powershell.exe ./ciBuildOrthancWin.ps1 publish ' + buildType
						}
					}
				}}
			}
		})
	}

	parallel(buildMap)
}}