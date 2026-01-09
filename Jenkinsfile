pipeline {
     agent any
    
    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_DEFAULT_REGION = 'eu-north-1'
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
                            "sudo yum update -y",
                            "sudo amazon-linux-extras install docker -y",
                            "sudo systemctl start docker",
                            "docker build -t my-node-app .",
                            "docker run -d -p 3000:3000 my-node-app"
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
                }

                echo "Application deployed! Access it at http://$EC2_PUBLIC_IP:3000
                '''
            }
        }
    }
}