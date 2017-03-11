# Jenkins Docker Image for DevOps CI/CD

Builds a Docker image from latest `jenkins:alpine` Docker image. Installs common DevOps tools.

## Installed Tools

- Python3
- pip3
- git
- OpenNTPD and tzdata
- AWS CLI
- HashiCorp Packer v0.12.3
- HashiCorp Terraform v0.8.8

## Commands
```bash
# create base image
image="garystafford/jenkins-devops"
docker build -t ${image}:latest .

docker rm -f jenkins-devops

# run new container from image
docker run -d \
  --name jenkins-devops \
  -p 8083:8080 \
  -p 50000:50000 \
  -v /tmp/jenkins_home:/var/jenkins_home \
  garystafford/jenkins-devops:latest

# 1x copy from container jenkins configuration to locally mounted volume
sudo docker cp jenkins-devops:/var/jenkins_home /tmp/jenkins_home

docker logs jenkins-devops
docker exec -it jenkins-devops /bin/bash

# Copy my aws keys to locally mounted volume
mkdir /tmp/jenkins_home/.ssh
cp ~/.ssh/aws_rsa* /tmp/jenkins_home/.ssh
```
