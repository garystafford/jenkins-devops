# Jenkins DevOps Docker Image

![Jenkins UI Preview](https://github.com/garystafford/jenkins-devops/blob/master/jenkins_preview.png)

Based on the latest [`jenkins:alpine`](https://hub.docker.com/_/jenkins) Docker image. Builds a new Docker image and installs some common DevOps tooling, frequently used with Jenkins. This Jenkins containerized implementation is designed to be an ephemeral CI/CD DevOps tool - stood up, used, and torn down, ideal for the Cloud.

## Installed Tools

Based on latest packages as of 3/24/2017 build:

- [AWS CLI](https://aws.amazon.com/cli/) v1.11.66
- [git](https://git-scm.com/)
- [HashiCorp Packer](https://www.packer.io/) v0.12.3
- [HashiCorp Terraform](https://www.terraform.io/) v0.9.1
- [jq](https://stedolan.github.io/jq/) v1.5
- [OpenNTPD](http://www.openntpd.org/) (time sync)
- [pip3](https://pip.pypa.io/en/stable/#)
- [Python3](https://www.python.org/) v3.5.2
- [tzdata](https://www.iana.org/time-zones) (time sync)

## Architecture

Fully configured, the Jenkins DevOps Docker container uses two bind-mounted directories on the host. The first, the Jenkins' home directory, contains all required configuration. The second directory is used for backups, created using the Jenkins Backup plugin. Additionally, Jenkins can back up its configuration, using the SCM Sync plugin, to GitHub. Both these backup methods require additional configuration.

![Jenkins DevOps Docker Image Architecture](https://github.com/garystafford/jenkins-devops/blob/master/architecture.png)

## Creating Image

### Adding Jenkins Plugins

The `Dockerfile` loads plugins from the `plugin.txt`. Currently, it installs two backup plugins. You can add more plugins to this file, before building Docker image. See the Jenkins [Plugins Index](https://plugins.jenkins.io/) for more.

```text
thinBackup:1.9
backup:1.6.1
```

### Create Image

Create the new `garystafford/jenkins-devops:latest` image from the Dockerfile.

```bash
image="garystafford/jenkins-devops"
docker build -t ${image}:latest .
```

The latest `garystafford/jenkins-devops` image is available on [Docker Hub](https://hub.docker.com/r/garystafford/jenkins-devops/).

## Using the Docker Image

### Preliminary Steps

Delete previous Jenkins container

```bash
docker rm -f jenkins-devops
```

Create bind-mounted `jenkins_home` directory on host

```bash
mkdir -p /tmp/jenkins_home/
```

Backup process with Jenkins' [backup](https://wiki.jenkins-ci.org/display/JENKINS/Backup+Plugin) plugin. Backups are saved to the bind-mounted host directory.

```bash
mkdir -p /tmp/backup/hudson
# docker exec -it jenkins-devops mkdir -p /tmp/backup/hudson
```

### Run the Container

Run new container from `garystafford/jenkins-devops:latest` image

```bash
docker run -d \
  --name jenkins-devops \
  -p 8083:8080 \
  -p 50000:50000 \
  -v /tmp/jenkins_home:/var/jenkins_home \
  -v /tmp/backup/hudson:/tmp/backup/hudson \
  garystafford/jenkins-devops:latest
```

Check container log for issues

```bash
docker logs jenkins-devops --follow
```

Jenkins will be running on [`http://localhost:8083`](http://localhost:8083), by default.

### Optional: AWS SSL Keys

Copy any required AWS SSL key pairs to bind-mounted `jenkins_home` directory.

```bash
mkdir -p /tmp/jenkins_home/.ssh

# used for git SCM Sync plugin
cp ~/.ssh/id_rsa /tmp/jenkins_home/.ssh

# used for Consul cluster project
cp ~/.ssh/consul_aws_rsa* /tmp/jenkins_home/.ssh
```

### Optional: AWS Credentials

Copy any required AWS credentials to bind-mounted `jenkins_home` directory

```bash
# used to connect to AWS with Packer/Terraform
cp ~/credentials/jenkins_credentials.env /tmp/jenkins_home/
```

## Troubleshooting

Fix time skew with container time:

```bash
docker run -it --rm --privileged \
  --pid=host debian nsenter -t 1 -m -u -n -i \
  date -u $(date -u +%m%d%H%M%Y)
```

## References

- [Jenkins by Docker](https://store.docker.com/images/d55eda09-d7f0-47b0-8780-3407f2f9142c?tab=description)
- [SCM Sync configuration plugin](https://wiki.jenkins-ci.org/display/JENKINS/SCM+Sync+configuration+plugin)
- [thinBackup](https://wiki.jenkins-ci.org/display/JENKINS/thinBackup)
- [Backup Plugin](https://wiki.jenkins-ci.org/display/JENKINS/Backup+Plugin)
