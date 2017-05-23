#!/bin/sh

# Deploy Jenkins DevOps container locally
# Not in swarm mode

set -e

mkdir -p /tmp/jenkins_home/.ssh/
mkdir -p /tmp/backup/hudson/

# ensure latest image is pulled...
docker pull garystafford/jenkins-devops:latest

docker-compose \
  -f docker-compose-local.yml \
  -p voterstack up \
  --force-recreate -d

docker rm $(docker ps -a -f status=exited -q) || echo "No containers to delete..."
docker image prune -f # clean up danglers...

echo "Letting services start-up..."
sleep 10

docker logs $(docker ps | grep jenkins-devops | awk '{print $1}')

echo "Script completed..."

echo "Jenkins available at: http://localhost:8083"
