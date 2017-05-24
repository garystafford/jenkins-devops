FROM jenkins:latest

LABEL maintainer "Gary A. Stafford <garystafford@rochester.rr.com>"
LABEL refreshed_at 2017-05-24

# switch to install packages via apt
USER root

# update and install common packages
RUN set -x \
  && apt-get update \
  && apt-get -y upgrade \
  && apt-get -y install openrc git openntpd tzdata python3 python3-pip jq \
  && python3 --version; docker --version; git --version; jq --version; pip3 --version

# update and install docker-ce and associated packages
RUN set -x \
  && apt-get install -y \
     lsb-release software-properties-common \
     apt-transport-https \
     ca-certificates \
     curl \
     gnupg2 \
  && curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
  && add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/debian \
    $(lsb_release -cs) \
    stable" \
  && apt-get update \
  && apt-get -y upgrade \
  && apt-get install -y docker-ce \
  && docker --version

RUN usermod -a -G staff,docker jenkins

# set timezone to America/New_York
RUN set -x \
  && ls /usr/share/zoneinfo \
  && cp /usr/share/zoneinfo/America/New_York /etc/localtime \
  && echo "America/New_York" >  /etc/timezone \
  && date

# install AWS cli
RUN set -x \
  && pip3 install awscli --upgrade \
  && exec bash

# confirm by checking vesion
RUN set -x \
  && aws --version

# install packer
RUN set -x \
  && packer_version="1.0.0" \
  && curl -O "https://releases.hashicorp.com/packer/${packer_version}/packer_${packer_version}_linux_amd64.zip" \
  && unzip packer_${packer_version}_linux_amd64.zip \
  && rm -rf packer_${packer_version}_linux_amd64.zip \
  && mv packer /usr/bin \
  && packer version

# install terraform
RUN set -x \
  && tf_version="0.9.5" \
  && curl -O "https://releases.hashicorp.com/terraform/${tf_version}/terraform_${tf_version}_linux_amd64.zip" \
  && unzip terraform_${tf_version}_linux_amd64.zip \
  && rm -rf terraform_${tf_version}_linux_amd64.zip \
  && mv terraform /usr/bin \
  && terraform version

# install plugins
COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN set -x \
  && /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt

# drop back to the regular jenkins user - good practice
USER jenkins
