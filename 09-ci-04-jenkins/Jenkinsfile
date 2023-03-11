pipeline {
    agent any

    stages {
        stage('Clone git Repo') {
            steps {
                git branch: 'main', credentialsId: '701b7581-1bb3-456b-9064-3e7a0226cf7f', url: 'git@github.com:duxaxa/lighthouse-role.git'
            }
        }
        stage('Test Role') {
            steps {
                sh 'pip3 install molecule molecule_docker'
                sh 'molecule test'
            }
        }
    }
}
