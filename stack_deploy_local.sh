#!/bin/sh

# Deploy Jenkins DevOps container locally
# Not in swarm mode

set -e

# Make local bind-mounted directories
mkdir -p /tmp/jenkins_home/.ssh/ || echo "Directory already exists..."
mkdir -p /tmp/jenkins_home/backups/ || echo "Directory already exists..."

# ensure latest image is pulled...
# docker pull garystafford/jenkins-devops:latest

# create Jenkins container
docker-compose \
  -f docker-compose-local.yml \
  -p demostack up \
  --force-recreate -d

# COnfigure Jenkins container
JENKINS_CONTAINER=$(docker ps | grep jenkins-devops | awk '{print $1}')
GIT_EMAIL="jenkins@jenkins.com"
GIT_USER="jenkins"

docker exec -it ${JENKINS_CONTAINER} \
  bash -c "mkdir /var/jenkins_home/backup/" || echo "Directory already exists..."
docker exec -it ${JENKINS_CONTAINER} \
  bash -c "git config --global user.email ${GIT_EMAIL}"
docker exec -it ${JENKINS_CONTAINER} \
  bash -c "git config --global user.name ${GIT_USER}"
docker exec -it ${JENKINS_CONTAINER} \
  bash -c "git clone git@github.com:garystafford/jenkins-config.git scm-sync-configuration/checkoutConfiguration" \
  || echo "An error occurred?!"


docker rm $(docker ps -a -f status=exited -q) || echo "No containers to delete..."
docker image prune -f # clean up danglers...

echo "Letting services start-up..."
sleep 10

docker logs $(docker ps | grep jenkins-devops | awk '{print $1}')

echo "Script completed..."

echo "Jenkins available at: http://localhost:8083"
