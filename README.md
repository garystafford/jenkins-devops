# Jenkins DevOps Docker Image

![Jenkins UI Preview](https://github.com/garystafford/jenkins-devops/blob/master/jenkins_preview.png)

Based on the latest [`jenkins:latest`](https://hub.docker.com/_/jenkins) Docker image. Builds a new Docker image and installs common DevOps tools and Jenkins plugins, frequently used with Jenkins, including Git, AWS CLI, Terraform, Packer, Python, Docker, and jq.

This Jenkins containerized implementation is designed to be an ephemeral CI/CD DevOps tool - stood up, used, and torn down, ideal for the Cloud.

## Installed Tools

Based on latest packages as of 6/2/2017 build:

- [AWS CLI](https://aws.amazon.com/cli/) v1.11.91
- [Git](https://git-scm.com/) 2.1.4
- [Docker](https://docker.com/) Docker version 17.06.0-ce, build 02c1d87
- [HashiCorp Packer](https://www.packer.io/) v1.0.2
- [HashiCorp Terraform](https://www.terraform.io/) v0.9.11
- [jq](https://stedolan.github.io/jq/) v1.4.1
- [OpenNTPD](http://www.openntpd.org/) (time sync)
- [pip3](https://pip.pypa.io/en/stable/#) v1.5.6
- [Python3](https://www.python.org/) v3.4.2
- [tzdata](https://www.iana.org/time-zones) (time sync)

## Architecture

Fully configured, the Jenkins DevOps Docker container uses two bind-mounted directories on the host. The first, the Jenkins' home directory, contains all required configuration. The second directory is used for backups, created using the Jenkins Backup plugin. Additionally, Jenkins can back up its configuration, using the SCM Sync plugin, to GitHub. Both these backup methods require additional configuration.

![Jenkins DevOps Docker Image Architecture](https://github.com/garystafford/jenkins-devops/blob/master/architecture.png)

## Quick Start
Don't want to read the instructions?
```bash
sh ./stack_deploy_local.sh
```
Jenkins will be running on [`http://localhost:8083`](http://localhost:8083).


## Optional: Adding Jenkins Plugins

The `Dockerfile` loads plugins from the `plugin.txt`. Currently, it installs two backup plugins. You can add more plugins to this file, before building Docker image. See the Jenkins [Plugins Index](https://plugins.jenkins.io/) for more.

```text
thinBackup:1.9
backup:1.6.1
```

## Optional: Create Docker Image

The latest `garystafford/jenkins-devops` image is available on [Docker Hub](https://hub.docker.com/r/garystafford/jenkins-devops/).

Optionally, to create a new image from the Dockerfile

```bash
docker build -t garystafford/jenkins-devops:latest .
```
## Run the Container

Create a new container from `garystafford/jenkins-devops:latest` image

```bash
sh ./stack_deploy_local.sh
```

Check logs
```bash
docker logs $(docker ps | grep jenkins-devops | awk '{print $1}')
```

This script also creates local directories `/tmp/jenkins_home/.ssh/` and `/tmp/jenkins_home/backups/`.  
All relevant Jenkins files are stored in bind-mounted `/tmp/jenkins_home/` directory.  
Backups are saved to the bind-mounted `/tmp/jenkins_home/backups/` host directory, using the Jenkins' [backup](https://wiki.jenkins-ci.org/display/JENKINS/Backup+Plugin) plugin.

Jenkins will be running on [`http://localhost:8083`](http://localhost:8083), by default.

## SCM

Install `scm-sync-configuration:0.0.10` plugin

Set git/GitHub repo path to your config repo, for example: `git@github.com:<your_username>/jenkins-config.git`

```bash
docker exec -it $(docker ps | grep jenkins-devops | awk '{print $1}') \
  bash -c 'git config --global user.email "<your@email.com>"'

docker exec -it $(docker ps | grep jenkins-devops | awk '{print $1}') \
  bash -c 'git config --global user.name "<your_username>"'
```

## Optional: AWS SSL Keys

Copy any required AWS SSL key pairs to bind-mounted `jenkins_home` directory.

```bash
mkdir -p /tmp/jenkins_home/.ssh

# used for git SCM Sync plugin
cp ~/.ssh/id_rsa /tmp/jenkins_home/.ssh/id_rsa

# used for Consul cluster project
cp ~/.ssh/consul_aws_rsa* /tmp/jenkins_home/.ssh
```

## Optional: AWS Credentials

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
