pipeline {
    agent any

    tools {
        nodejs 'node-20' 
    }

    environment {
        BACKEND_IMAGE = 'jegy-backend:latest'
        FRONTEND_IMAGE = 'jegy-frontend:latest'
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }

        stage('Install & Test Backend') {
            steps {
                dir('server') {
                    echo 'Installing Backend dependencies...'
                    sh 'npm install'
                    
                    echo 'Running Backend tests...'
                    sh 'npm test'
                }
            }
        }

        stage('Install & Test Frontend') {
            steps {
                dir('client/jegyertekesito') {
                    echo 'Installing Frontend dependencies...'
                    sh 'npm install'
                    
                    echo 'Building Frontend...'
                    sh 'npm run build' 
                }
            }
        }

        stage('Build Docker Images') {
            steps {
                script {
                    echo 'Building Backend Docker Image...'
                    dir('server') {
                        sh "docker build -t ${BACKEND_IMAGE} ."
                    }

                    echo 'Building Frontend Docker Image...'
                    dir('client/jegyertekesito') {
                        sh "docker build -t ${FRONTEND_IMAGE} ."
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline futtatása sikeres.'
        }
        failure {
            echo 'Hiba a pipeline futása közben.'
        }
    }
}