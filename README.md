# TITLE: INFRASTRUCTURE AND CONTAINER AUTOMATION WITH JENKINS

## Description
This project demonstrates an end-to-end CI/CD pipeline that automates infrastructure provisioning and containerized application deployment using Terraform, Docker, and Jenkins.

Infrastructure is defined and manged as code with Terraform, ensuring consistent and repeatable cloud resource creation. Jenkins is used to orchestrate the pipeline, handling stages such as initializing terraform, planning and applying terraform to provision infrastructure on AWS cloud platform instead of going through manual provisioning of infrastructure,building Docker images, pushing them to a container registry, and deploying the application on provisioned infrastructure. Docker enables application containerization for portability and environment consistency.

The goal of this project is to showcase practical DevOps skills, including Infrastructure as Code (IaC), CI/CD automation, containerization, and cloud deployment best practices.

## Tools & Technologies
- Terraform - Infrastructure as Code
- Jenkins - CI/CD pipeline automation
- Docker - Application containerization
- AWS (EC2, S3, IAM, VPC)

## Project Workflow
- The Jenkins pipeline is triggered manually.
- Jenkins executes the CI/CD stages defined in the Jenkinsfile.
- Terraform provisions the required cloud infrastructure.
- Docker builds the application image.
- The image is pushed to acontainer registry.
- The application is deployed on the provisioned infrastructure.

## Setting Up The Project
There're some steps involve in setting up the project.
### 1. Authentiaction
 Authentiacate into AWS account using AWS account credentials with the command:
```bash
aws configure
```
But before running this command, make sure aws cli has been installed.

### 2. Creating Folder for the Project 
Create a new folder in home directory, and in that folder,create a new folder named "terrafom-config" which consists of compute.tf file for EC2, networking.tf for VPC, provider.tf, output.tf, terraform.tfvars, and variable.tf files for provisioning the infrastucture to be used for deployment of this project.

### 3. Creating Files in the Project Folder. 
Create a Dockerfile, index.js file, Jenkinsfile, and .gitignore, and .dockerignore file in the folder created.

### 4. Jenkins Declarative Pipeline.
Write a Jenkins Declarative Pipeline in Jenkinsfile that include different stages for initializing terraform, planning, applying terraform, to the stage for creating S3 bucket which is used for storing terraform.tfstate, to the stage that tells Jenkins to build Docker image and push to docker hub which serves as docker registry to be used for this project, and finally to the stage that tells Jenkins to deploy the docker image via SSM.

### 5.Plugins Installation and Credentials. 
 Login to Jenkins browser through localhost machine, add necessary credentials(AWS Credentials, Docker Hub Credentials, Git Credentials) to Jenkins Credentials, and install necessary plugins to ensure smooth running of Jenkins pipeline.

After successful installation of plugins and adding of credentials, go straight to creating new item and select "Pipeline", another page will be opened which shows Pipeline, click on Definition under Pipeline and select Pipeline sript from SCM, select Git for the SCM, and input Repository URL, select Git credentials among the credentials shown, input the repository branch to build and click on apply which will build the Jenkins pipeline.

## Conclusion
 This project demonstrates an end-to-end DevOps CI/CD pipeline that integrates Terraform, Docker, and Jenkins to automate infrastructure provisioning and containerized application deployment. It highlights key DevOps practices such as Infrastructure as Code, CI/CD automation, and reproducible deployments. 



