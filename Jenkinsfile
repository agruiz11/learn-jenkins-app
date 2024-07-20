pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID = '49a2d938-3508-4234-8695-1c60c7a097ea'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
        REACT_APP_VERSION = "1.0.$BUILD_ID"
    }

    stages {
        stage('AWS') {
            agent {
                docker {
                    image 'amazon/aws-cli'
                    args "--entrypoint=''"
                    reuseNode true
                }
            } 

            steps {
                withCredentials([usernamePassword(credentialsId: 'My-AWS', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh '''
                        aws --version
                        aws ecs register-task-definition --cli-input-json file://aws/task-defination.json --region us-east-2
                    '''
                }
            }
        }


        stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    echo "SMALL CHANGE"
                    ls -al
                    node --version
                    npm --version
                    npm ci
                    npm run build
                    ls -al
                '''
            }
        }
    }
}