# Jenkins Docker Image for DevOps CI/CD

Builds a Docker image from latest `[jenkins:alpine](https://hub.docker.com/_/jenkins/)` Docker image. Installs common DevOps tools. Jenkins will be running on `http://localhost:8083`, by default.

## Installed Tools

- Python3
- pip3
- git
- OpenNTPD and tzdata (time sync)
- AWS CLI
- HashiCorp Packer v0.12.3
- HashiCorp Terraform v0.8.8

## Commands

### Docker image

Create the new `garystafford/jenkins-devops:latest` image from the Dockerfile.

```bash
image="garystafford/jenkins-devops"
docker build -t ${image}:latest .
```

### Create Jenkins Container

```bash
# make locally mounted directory for jenkins_home in container
mkdir -p /tmp/jenkins_home/

# delete previous containers
docker rm -f jenkins-devops

# run new container from image
docker run -d \
  --name jenkins-devops \
  -p 8083:8080 \
  -p 50000:50000 \
  -v /tmp/jenkins_home:/var/jenkins_home \
  -v /tmp/backup/hudson:/tmp/backup/hudson \
  garystafford/jenkins-devops:latest

docker logs jenkins-devops
```

### AWS Keys

Copy my AWS key pair to the locally mounted volume for use with Terraform.

```bash
mkdir -p /tmp/jenkins_home/.ssh
cp ~/.ssh/aws_rsa* /tmp/jenkins_home/.ssh
```

### Backup

Backup process with Jenkins backup plugin. Full backups will be placed in the locally mounted directory.

```bash
mkdir -p /tmp/backup/hudson
docker exec -it jenkins-devops mkdir -p /tmp/backup/hudson
```
