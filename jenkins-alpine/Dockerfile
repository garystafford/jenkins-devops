FROM jenkins:alpine

LABEL maintainer "Gary A. Stafford <garystafford@rochester.rr.com>"
LABEL refreshed_at 2017-05-24

# switch to install packages via apk
USER root

# update and install tools including python3
RUN set -x \
  echo "http://dl-6.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
  && apk update \
  && apk upgrade \
  && apk add openrc git openntpd tzdata python3 jq \
  && python3 --version; docker --version; git --version; jq --version

# set timezone to America/New_York
RUN set -x \
  && ls /usr/share/zoneinfo \
  && cp /usr/share/zoneinfo/America/New_York /etc/localtime \
  && echo "America/New_York" >  /etc/timezone \
  && date \
  && apk del tzdata

# install pip
RUN set -x \
  && curl -O https://bootstrap.pypa.io/get-pip.py \
  && python3 get-pip.py --user \
  && exec bash

# upgrade pip
RUN set -x \
  && pip3 install --upgrade pip \
  && pip3 --version

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
