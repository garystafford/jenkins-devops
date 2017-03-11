# Jenkins CI with DevOps tools
Builds Docker image from latest jenkins:alpine Docker image and installs the following tool:
* Python3
* pip3
* git
* OpenNTPD and tzdata
* AWS CLI
* HashiCorp Packer v0.12.3
* HashiCorp Terraform v0.8.8

```bash
sudo docker cp jenkins-dev:/var/jenkins_home /tmp/jenkins_home

image="garystafford/jenkins"
docker build -t ${image}:alpine .

docker rm -f jenkins-dev

docker run -d \
  --name jenkins-dev \
  -p 8083:8080 \
  -p 50000:50000 \
  -v /tmp/jenkins_home:/var/jenkins_home \
  garystafford/jenkins:alpine

# 1x copy configuration to locally mounted volume
# sudo docker cp jenkins-dev:/var/jenkins_home /tmp/jenkins_home

docker logs jenkins-dev
docker exec -it jenkins-dev /bin/bash

# sudo docker cp jenkins-dev:/var/jenkins_home /tmp/jenkins_home

mkdir /tmp/jenkins_home/.ssh
cp ~/.ssh/consul_aws_rsa* /tmp/jenkins_home/.ssh
```
