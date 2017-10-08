#!/bin/sh

# Deploy Jenkins DevOps container locally
# Not in swarm mode

set -e

# variables
IMAGE_TAG="2017.10.07"
GIT_EMAIL="jenkins@jenkins.com"
GIT_USER="jenkins"

# Make local bind-mounted directories
mkdir -p /tmp/jenkins_home/.ssh/ || echo "Directory already exists..."
mkdir -p /tmp/jenkins_home/backup/ || echo "Directory already exists..."

# ensure latest image is pulled...
docker pull garystafford/jenkins-devops:${IMAGE_TAG}

# create Jenkins container
docker-compose \
  -f docker-compose-local.yml \
  -p devopstack up \
  --force-recreate -d

# Configure Jenkins container
JENKINS_CONTAINER=$(docker ps | grep jenkins-devops | awk '{print $1}')
docker exec -it ${JENKINS_CONTAINER} \
  bash -c "mkdir /var/jenkins_home/backup/" || echo "Directory already exists..."
docker exec -it ${JENKINS_CONTAINER} \
  bash -c "git config --global user.email ${GIT_EMAIL}"
docker exec -it ${JENKINS_CONTAINER} \
  bash -c "git config --global user.name ${GIT_USER}"
# docker exec -u root -it ${JENKINS_CONTAINER} \
# bash -c "git clone git@github.com:garystafford/jenkins-config.git scm-sync-configuration/checkoutConfiguration" \
# || echo 'An error occurred?!'

# docker rm $(docker ps -a -f status=exited -q) || echo "No containers to delete..."
# docker image prune -f # clean up danglers...

echo "Letting services start-up..."
sleep 30
docker logs $(docker ps | grep jenkins-devops | awk '{print $1}')

echo "Script completed..."

echo "Jenkins available at: http://localhost:8083"
ADMIN_PASSWORD=$(cat /tmp/jenkins_home/secrets/initialAdminPassword)
echo "Unlock Jenkins: ${ADMIN_PASSWORD}"
