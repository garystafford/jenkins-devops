FROM jenkins/jenkins:latest

LABEL maintainer "Gary A. Stafford <garystafford@rochester.rr.com>"
ENV REFRESHED_AT 2017-10-08

# switch to install packages via apt
USER root

# update and install common packages
RUN set -x \
  && apt-get update \
  && apt-get -y upgrade \
  && apt-get -y install openrc git openntpd tzdata python3 python3-pip jq

# update and install Docker CE and associated packages
RUN set -x \
  && apt-get install -y \
     lsb-release software-properties-common \
     apt-transport-https ca-certificates curl gnupg2 \
  && curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
  && add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/debian \
    $(lsb_release -cs) \
    stable" \
  && apt-get update \
  && apt-get -y upgrade \
  && apt-get install -y docker-ce

RUN set -x \
  && usermod -aG staff,docker jenkins \
  && exec bash

# install Docker Compose
RUN set -x \
  && curl -L https://github.com/docker/compose/releases/download/1.16.1/docker-compose-`uname -s`-`uname -m` > docker-compose \
  && cp docker-compose /usr/local/bin/docker-compose \
  && chmod +x /usr/local/bin/docker-compose

# install AWS CLI
RUN set -x \
  && pip3 install awscli --upgrade \
  && exec bash

# install HasiCorp Packer
RUN set -x \
  && packer_version="1.1.0" \
  && curl -O "https://releases.hashicorp.com/packer/${packer_version}/packer_${packer_version}_linux_amd64.zip" \
  && unzip packer_${packer_version}_linux_amd64.zip \
  && rm -rf packer_${packer_version}_linux_amd64.zip \
  && mv packer /usr/bin

# install HasiCorp Terraform
RUN set -x \
  && tf_version="0.10.7" \
  && curl -O "https://releases.hashicorp.com/terraform/${tf_version}/terraform_${tf_version}_linux_amd64.zip" \
  && unzip terraform_${tf_version}_linux_amd64.zip \
  && rm -rf terraform_${tf_version}_linux_amd64.zip \
  && mv terraform /usr/bin

# install Jenkins plugins
COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN set -x \
  && /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt

# list installed software versions
RUN set +x \
  && echo ''; echo '*** INSTALLED SOFTWARE VERSIONS ***';echo ''; \
  cat /etc/*release; python3 --version; \
  docker --version; docker-compose version; \
  git --version; jq --version; pip3 --version; aws --version; \
  packer version; terraform version; echo '';

RUN set -x \
  && apt-get clean

# set timezone to America/New_York
RUN set -x \
  && ls /usr/share/zoneinfo \
  && cp /usr/share/zoneinfo/America/New_York /etc/localtime \
  && echo "America/New_York" >  /etc/timezone \
  && date

# drop back to the regular jenkins user - good practice
USER jenkins
