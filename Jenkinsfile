pipeline{
    agent any
    tools{
        jdk 'jdk17'
        nodejs 'node16'
    }
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
    }
    stages{
        stage('clean workspace'){
            steps{
                cleanWs()
            }
        }
        stage('Checkout from git'){
            steps{
                git branch: 'feature-yt-clone-app', url: 'https://github.com/faiz1487/youtube_clone.git'
            }
        }
        stage('Sonarqube Analysis'){
            steps{
                withSonarQubeEnv('SonarQube-Server') {
                    sh """
                    ${SCANNER_HOME}/bin/sonar-scanner \
                    -Dsonar.projectKey=Youtube-CICD \
                    -Dsonar.sources=. \
                    -Dsonar.host.url=http://65.0.103.43:9000 \
                    -Dsonar.login=squ_9c37fa889b1920b323dd99ef740ecfad89ba5e08
                    """
                }
            }
        }
        stage('Quality Gate'){
            steps{
                script{
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonarQube-Token'
                }
            }
        }
        stage('Install Dependencies'){
            steps{
                sh 'npm install'
            }
        }
        stage('Trivy scan'){
            steps{
                sh '''
                trivy fs --severity HIGH,CRITICAL --exit-code 1 . | tee trivyfs.txt
                '''
            }
        }
        stage('Docker build & push'){
            steps{
                withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    sh """
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    docker build -t youtube-clone .
                    docker tag youtube-clone $DOCKER_USER/youtube-clone:latest 
                    docker push $DOCKER_USER/youtube-clone:latest
                    docker logout
                    """
                }
            }
        }
        stage('scan docker image using Trivy'){
            steps{
                sh "trivy image faiz18887/youtube-clone:latest > trivyimage.txt "
            }
        }
        stage('Deploy to EKS cluster'){
            steps{
                script{
                    dir('kubernetes'){
                        withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: 'kubernetes', namespace: '', restrictKubeConfigAccess: false, serverUrl: ''){
                            sh"""
                            kubectl delete --all pods
                            kubectl apply -f deployment.yaml
                            kubectl apply -f service.yaml
                            """
                        }
                    }
                }
            }
        }
    }
}
