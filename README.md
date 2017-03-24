# Jenkins Docker Image for DevOps CI/CD

Builds a Docker image from latest [`jenkins:alpine`](https://hub.docker.com/_/jenkins) Docker image. Installs common DevOps tooling. Jenkins will be running on [`http://localhost:8083`](http://localhost:8083), by default.

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
# delete previous containers
docker rm -f jenkins-devops

# create bind-mounted jenkins_home directory on host
mkdir -p /tmp/jenkins_home/

# run new container from image
docker run -d \
  --name jenkins-devops \
  -p 8083:8080 \
  -p 50000:50000 \
  -v /tmp/jenkins_home:/var/jenkins_home \
  -v /tmp/backup/hudson:/tmp/backup/hudson \
  garystafford/jenkins-devops:latest

# check container log for issues
docker logs jenkins-devops
```

### AWS SSL Keys

Copy any required AWS SSL key pairs to bind-mounted `jenkins_home` directory.

```bash
mkdir -p /tmp/jenkins_home/.ssh
cp ~/.ssh/consul_aws_rsa* /tmp/jenkins_home/.ssh
```

### AWS credentials

Copy any required AWS credentials to bind-mounted `jenkins_home` directory

```bash
cp ~/credentials/jenkins_credentials.env /tmp/jenkins_home/
```

### Backup Directories

Backup process with Jenkins backup plugin. Backups will be placed in the locally mounted directory.

```bash
mkdir -p /tmp/backup/hudson
docker exec -it jenkins-devops mkdir -p /tmp/backup/hudson
```

### Troubleshooting

Fix time skew with container time:

```bash
docker run -it --rm --privileged --pid=host debian nsenter -t 1 -m -u -n -i date -u $(date -u +%m%d%H%M%Y)
```
