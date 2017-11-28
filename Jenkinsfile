lock(resource: 'orthanc-bundles', inversePrecedence: false) {

    stage('Build') {
        node('master && docker') { wrap([$class: 'AnsiColorBuildWrapper']) {

            checkout scm

            sh 'ciBuild.sh ${BRANCH_NAME}'
        }}
    }

}