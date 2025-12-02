pipeline {
    agent any

    tools {
        nodejs 'node-20'
    }

    environment {
        DOCKERHUB_USER = 'zato7777'
        BACKEND_IMAGE = '${DOCKERHUB_USER}/jegy-backend:latest'
        FRONTEND_IMAGE = '${DOCKERHUB_USER}/jegy-frontend:latest'
        DOCKER_CREDENTIALS = credentials('dockerhub-login')
        KUBECONFIG = credentials('kubeconfig')
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
                    sh 'echo $DOCKER_CREDENTIALS_PSW | docker login -u $DOCKER_CREDENTIALS_USR --password-stdin'

                    echo 'Building Backend Docker Image...'
                    dir('server') {
                        sh "docker build -t ${BACKEND_IMAGE} ."
                        sh "docker push ${BACKEND_IMAGE}"
                    }

                    echo 'Building Frontend Docker Image...'
                    dir('client/jegyertekesito') {
                        sh "docker build -t ${FRONTEND_IMAGE} ."
                        sh "docker push ${FRONTEND_IMAGE}"
                    }

                    sh 'docker logout'
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
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