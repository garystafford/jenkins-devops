#!/bin/sh

# Deploy Jenkins DevOps container locally
# Not in swarm mode

set -e

IMAGE_TAG="2018.04.19"

# ensure latest jenkins image is pulled and used as base images...
docker pull jenkins/jenkins:latest

# build new image
docker build --file Dockerfile \
  --no-cache \
  -t garystafford/jenkins-devops:${IMAGE_TAG} .
