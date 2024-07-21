pipeline {
    agent any

    environment {
        REACT_APP_VERSION = "1.0.$BUILD_ID"
        APP_NAME = 'my-jenkins-app'
        AWS_DEFAULT_REGION = "us-east-2"
        AWS_ECR = '000168738829.dkr.ecr.us-east-2.amazonaws.com'
        AWS_ECS_CLUSTER = 'Jenkins-Cluster' 
        AWS_ECS_SERVICE = 'jenkinsApp-Service'
        AWS_ECS_TD = 'JenkinsApp-TaskDef'
    }

    stages {
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

        stage('Build Docker Image') {
            agent {
                docker {
                    image 'my-aws-cli'
                    args "-u root -v /var/run/docker.sock:/var/run/docker.sock --entrypoint=''"
                    reuseNode true
                }
            } 

            steps {
                withCredentials([usernamePassword(credentialsId: 'My-AWS', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh '''
                        docker build -t $AWS_ECR/$APP_NAME:$REACT_APP_VERSION .
                        aws ecr get-login-password | docker login --username AWS --password-stdin $AWS_ECR 
                        docker push $AWS_ECR/$APP_NAME:$REACT_APP_VERSION
                    '''
                }
            }
        }

        stage('AWS') {
            agent {
                docker {
                    image 'my-aws-cli' 
                    args "--entrypoint=''"
                    reuseNode true
                }
            } 

            steps {
                withCredentials([usernamePassword(credentialsId: 'My-AWS', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh '''
                        aws --version
                        sed -i "s/#APP_VERSION#/$REACT_APP_VERSION/g" aws/task-defination.json
                        LATEST_TD_REVISION=$(aws ecs register-task-definition --cli-input-json file://aws/task-defination.json | jq '.taskDefinition.revision')
                        aws ecs update-service --service $AWS_ECS_SERVICE --task-definition $AWS_ECS_TD:$LATEST_TD_REVISION --cluster $AWS_ECS_CLUSTER
                        aws ecs wait services-stable --cluster $AWS_ECS_CLUSTER --services $AWS_ECS_SERVICE
                    '''
                }
            }
        }
    }
}