# Jenkins DevOps Toolkit

The project's goal is to provide a light-weight, ready-made, easily-modifiable DevOps toolkit in a Docker container. The container toolkit includes the latest copies of Jenkins, Jenkins plugins, and the most common DevOps tools frequently used with Jenkins. These DevOps tools include Git, AWS CLI, Terraform, Packer, Python, Docker, Docker Compose, cURL, and jq. The container is designed to be a short-lived, stood up, used for CI/CD, and torn down, and is ideal for the Cloud.

![Jenkins UI Preview](https://github.com/garystafford/jenkins-devops/blob/master/pics/jenkins_startup.png)

![Jenkins UI Preview](https://github.com/garystafford/jenkins-devops/blob/master/pics/jenkins_preview2.png)

The `Jenkins DevOps Toolkit` image is based on the latest [`jenkins/jenkins:latest`](https://hub.docker.com/r/jenkins/jenkins/) Docker image. The Jenkins Docker image is based on [Debian GNU/Linux 9.1 (stretch)](https://wiki.debian.org/DebianStretch).

## Installed Tools

Based on latest packages as of 10/07/2017:

- [AWS CLI](https://aws.amazon.com/cli/) v1.11.167
- [Docker CE](https://docker.com/) v17.09.0-ce
- [Docker Compose](https://docs.docker.com/compose/) v1.16.1
- [Git](https://git-scm.com/) v2.11.0
- [HashiCorp Packer](https://www.packer.io/) v1.1.0
- [HashiCorp Terraform](https://www.terraform.io/) v0.10.7
- [Jenkins](https://jenkins.io/) v2.82
- [jq](https://stedolan.github.io/jq/) v1.5.1
- [OpenNTPD](http://www.openntpd.org/) (time sync)
- [pip3](https://pip.pypa.io/en/stable/#) v9.0.1
- [Python3](https://www.python.org/) v3.5.3
- [tzdata](https://www.iana.org/time-zones) (time sync)

```text
PRETTY_NAME="Debian GNU/Linux 9 (stretch)"
Python 3.5.3
Docker version 17.09.0-ce, build afdb6d4
docker-compose version 1.16.1, build 6d1ac21
docker-py version: 2.5.1
CPython version: 2.7.13
OpenSSL version: OpenSSL 1.0.1t  3 May 2016
git version 2.11.0
jq-1.5-1-a5b5cbe
pip 9.0.1 from /usr/lib/python3/dist-packages (python 3.5)
aws-cli/1.11.167 Python/3.5.3 Linux/4.9.49-moby botocore/1.7.25
Packer v1.1.0
Terraform v0.10.7
```

## Architecture

The Jenkins DevOps Toolkit Docker container uses two bind-mounted directories on the host. The first, the Jenkins' home directory, contains all required configuration. The second directory is used for backups, created using the Jenkins Backup plugin. Additionally, Jenkins can back up its configuration, using the SCM Sync plugin, to GitHub. Both these backup methods require additional configuration.

![Jenkins DevOps Docker Image Architecture](https://github.com/garystafford/jenkins-devops/blob/master/pics/architecture.png)

## Quick Start

Don't want to read the instructions?

```bash
sh ./stack_deploy_local.sh
```

Jenkins will be running on [`http://localhost:8083`](http://localhost:8083).

## Optional: Adding Jenkins Plugins

The `Dockerfile` loads plugins from the `plugin.txt`. Currently, it installs two backup plugins. You can add more plugins to this file, before building Docker image. See the Jenkins [Plugins Index](https://plugins.jenkins.io/) for more.

```text
Downloading thinBackup:1.9
Downloading backup:1.6.1
---------------------------------------------------
INFO: Successfully installed 2 plugins.
---------------------------------------------------
```

## Optional: Create Docker Image

The latest `garystafford/jenkins-devops` image is available on [Docker Hub](https://hub.docker.com/r/garystafford/jenkins-devops/).

Optionally, to create a new image from the Dockerfile

```bash
docker build -t garystafford/jenkins-devops:2017.10.07 .
```

## Run the Container

Create a new container from `garystafford/jenkins-devops:2017.10.07` image

```bash
sh ./stack_deploy_local.sh
```

Check logs

```bash
docker logs $(docker ps | grep jenkins-devops | awk '{print $1}')
```

This script also creates local directories `/tmp/jenkins_home/.ssh/` and `/tmp/jenkins_home/backups/`.<br>
All relevant Jenkins files are stored in bind-mounted `/tmp/jenkins_home/` directory.<br>
Backups are saved to the bind-mounted `/tmp/jenkins_home/backups/` host directory, using the Jenkins' [backup](https://wiki.jenkins-ci.org/display/JENKINS/Backup+Plugin) plugin.

Jenkins will be running on [`http://localhost:8083`](http://localhost:8083), by default.

## SCM

Install the SCM Sync Configuration Plugin (`scm-sync-configuration:0.0.10`)

Set git/GitHub repo path to your config repo, for example: `https://<personal_access_token>@github.com/<your_username>/jenkins-config.git`

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
cp ~/.ssh/id_rsa.pub /tmp/jenkins_home/.ssh/id_rsa.pub

# in container for cloning config if on github
docker exec -it $(docker ps | grep jenkins-devops | awk '{print $1}') \
  bash -c 'ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts'


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

## Further Development

To modify, build, and test locally, replacing my Docker Hub repo name swith your own:

```bash
# build
docker build --no-cache -t garystafford/jenkins-devops:2017.10.07 .

# run temp copy only
docker run -d --name jenkins-temp -p 8083:8080/tcp -p 50000:50000/tcp garystafford/jenkins-devops:2017.10.07

# push
docker push garystafford/jenkins-devops:2017.10.07

# clean up container and local bind-mounted directory
rm -rf /tmp/jenkins_home
docker rm -f devopstack_jenkins-devops_1
```

## References

- [Jenkins by Docker](https://hub.docker.com/r/jenkins/jenkins/)
- [SCM Sync configuration plugin](https://wiki.jenkins-ci.org/display/JENKINS/SCM+Sync+configuration+plugin)
- [thinBackup](https://wiki.jenkins-ci.org/display/JENKINS/thinBackup)
- [Backup Plugin](https://wiki.jenkins-ci.org/display/JENKINS/Backup+Plugin)
