pipeline {
     agent any
    
    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_DEFAULT_REGION = 'eu-north-1'
        DOCKER_IMAGE = 'my-node-app'
    } 
    
    stages {
        stage('Git Checkout'){
            steps {
                git branch: 'main', url:'https://github.com/Adeife79/IaC-Pipeline.git'
            }
        }
    

        stage ('Create S3 Bucket') {
            environment {
                AWS_DEFAULT_REGION = 'eu-north-1'
                BUCKET_NAME = "adeife-terraform-state-bucket"
            }
                
             steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins-creds'
                ]]) {
        
                    sh '''
                        aws s3api create-bucket --bucket "$BUCKET_NAME" --region eu-north-1 --create-bucket-configuration LocationConstraint=eu-north-1
                    '''
                }
            }
        }

        stage('Terraform Init'){
            steps {
                dir('terraform-config') {
                     sh 'terraform init -input=false -migrate-state'
                }
            }
        }
        
        stage('Terraform Plan'){
            steps {
                dir('terraform-config') {
                    sh 'terraform plan -out=tfplan -input=false'
                }
            }
        }
    
        stage('Terraform Apply') {
            steps {
                dir('terraform-config') {
                    sh 'terraform apply -input=false -auto-approve tfplan'
                }       
            }
        }

        stage('Build Docker Image and Push to Docker Hub'){
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        #docker build -t $DOCKER_IMAGE .
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker tag $DOCKER_IMAGE $DOCKER_USER/$DOCKER_IMAGE
                        docker push $DOCKER_USER/$DOCKER_IMAGE
                    '''
                }
            }
        }

        stage('Build and Run Docker App via SSM') {
            steps {
                script { 
                    env.EC2_PUBLIC_IP = sh(
                        script: "cd terraform-config && terraform output -raw ec2_public_ip",
                        returnStdout: true
                    ).trim()
                    env.INSTANCE_ID = sh(
                        script: 'cd terraform-config && terraform output -raw instance_id',
                        returnStdout: true
                    ).trim()
                }

                sh '''
                    aws ec2 wait instance-running --instance-id $INSTANCE_ID --region $AWS_DEFAULT_REGION

                    COMMAND_ID=$(aws ssm send-command \
                        --instance-id $INSTANCE_ID \
                        --document-name "AWS-RunShellScript" \
                        --parameters 'commands=[
                            "DOCKER_USER=elizabeth190",
                            "DOCKER_IMAGE=my-node-app:latest",
                            "sudo systemctl start amazon-ssm-agent || true",
                            "sudo systemctl enable amazon-ssm-agent || true",
                            "sudo dnf update -y >/dev/null 2>&1 || true",
                            "sudo systemctl daemon-reload || true",
                            "sudo dnf install -y docker || true",
                            "sudo systemctl start docker 2>/dev/null || true",
                            "sudo systemctl enable docker 2>/dev/null || true",
                            "docker pull $DOCKER_USER/$DOCKER_IMAGE || true",
                            "docker run -d -p 3000:3000 $DOCKER_USER/$DOCKER_IMAGE || true"
                            ]' \
                        --region $AWS_DEFAULT_REGION \
                        --query "Command.CommandId" \
                        --output text)
                    echo "Docker deployment command sent. Command ID: $COMMAND_ID"

                    aws ssm wait command-executed \
                        --command-id  $COMMAND_ID \
                        --instance-id $INSTANCE_ID \
                        --region $AWS_DEFAULT_REGION

                    aws ssm get-command-invocation \
                        --command-id $COMMAND_ID \
                        --instance-id $INSTANCE_ID \
                        --region $AWS_DEFAULT_REGION 
                '''
                echo "Application deployed! Access it at http://$EC2_PUBLIC_IP:3000"
            }
        }
    }
}