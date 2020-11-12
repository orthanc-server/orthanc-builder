try {
    lock(resource: 'orthanc-bundles', inversePrecedence: false) {

        stage('Build') {
            node('docker && builder') { 
                wrap([$class: 'AnsiColorBuildWrapper']) {

                    withCredentials(bindings: [sshUserPrivateKey(credentialsId: 'bitbucket-osimis', \
                                    keyFileVariable: 'SSH_KEY_ABC', \
                                    passphraseVariable: '', \
                                    usernameVariable: '')]) {

                        checkout scm
                        sh '''
                            GIT_SSH_COMMAND='ssh -i $SSH_KEY_ABC -o IdentitiesOnly=yes' git submodule update --init
                            '''
                        // we need AWS credentials to push vcpkg packages for the orthanc-pro images
                        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-orthanc.osimis.io']]) {
                            sh './ciBuild.sh ${BRANCH_NAME} build'
                        }

                        docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-jenkinsosimis') {
                            sh './ciBuild.sh ${BRANCH_NAME} pushToPublicRepo'
                        }

                        docker.withRegistry('https://osimis.azurecr.io/v2/', 'jenkins-push-azure-osimis-cr') {
                            sh './ciBuild.sh ${BRANCH_NAME} pushToPrivateRepo'
                        }
                    }
                }
            }
        }

    }
}
catch (e) {
    slackSend channel: 'jenkins-orthanc', color: '#FF0000', message: "${env.JOB_NAME} has failed ${env.JOB_URL}"
    throw e
}