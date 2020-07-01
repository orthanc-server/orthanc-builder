try {
	lock(resource: 'orthanc-bundles', inversePrecedence: false) {

	    stage('Build') {
	        node('master && docker') { wrap([$class: 'AnsiColorBuildWrapper']) {
              docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-jenkinsosimis') {
	                checkout scm
									sh 'git submodule update --init'

	                sh './ciBuild.sh ${BRANCH_NAME}'
              }
				  }}
	    }
		    // slackSend channel: 'jenkins-orthanc', color: '#FF0000', message: "${env.JOB_NAME} has succeded ${env.JOB_URL}"

	}

}
catch (e) {
    slackSend channel: 'jenkins-orthanc', color: '#FF0000', message: "${env.JOB_NAME} has failed ${env.JOB_URL}"
    throw e
}