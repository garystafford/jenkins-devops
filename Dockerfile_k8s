FROM jenkins/jenkins:latest

LABEL maintainer "Gary A. Stafford <garystafford@rochester.rr.com>"
ENV REFRESHED_AT 2018-04-25

# set variables - *** CHANGE ME ***
ARG istio_version="0.7.1"
ARG google_cloud_sdk="199.0.0"
ARG timezone="America/New_York"

ENV ISTIO_VERSION $istio_version
ENV ISTIO_HOME "/bin/istio-${ISTIO_VERSION}"
ENV GOOGLE_CLOUD_SDK $google_cloud_sdk
ENV GOOGLE_CLOUD_SDK_HOME="/bin/google-cloud-sdk"
ENV PATH="${ISTIO_HOME}/bin:${GOOGLE_CLOUD_SDK_HOME}/bin:${PATH}"
ENV TIMEZONE $timezone

# switch to install packages via apt
USER root

# update and install common packages
RUN set +x \
  && env \
  && apt-get update \
  && apt-get -y upgrade \
  && apt-get -y install openrc openntpd tzdata python3 python3-pip jq git

# update and install Docker CE and associated packages
RUN set +x \
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
  && apt-get install -y docker-ce \
  && systemctl enable docker

# set permissions for jenkins user
RUN set +x \
    && usermod -aG staff,docker jenkins \
  && exec bash

# install google-cloud-sdk (gcloud and kubectl)
RUN set +x \
  && wget "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GOOGLE_CLOUD_SDK}-linux-x86_64.tar.gz" \
  && tar -xvzf google-cloud-sdk-${GOOGLE_CLOUD_SDK}-linux-x86_64.tar.gz \
  && rm -rf google-cloud-sdk-${GOOGLE_CLOUD_SDK}-linux-x86_64.tar.gz \
  && mv google-cloud-sdk /bin \
  && sh ./bin/google-cloud-sdk/install.sh \
      --usage-reporting no \
      --additional-components kubectl alpha beta \
      --quiet

# install Istio
RUN set +x \
  && wget "https://github.com/istio/istio/releases/download/${ISTIO_VERSION}/istio-${ISTIO_VERSION}-linux.tar.gz" \
  && tar -xvzf istio-${ISTIO_VERSION}-linux.tar.gz \
  && rm -rf istio-${ISTIO_VERSION}-linux.tar.gz \
  && mv istio-${ISTIO_VERSION} /bin

# install jenkins plugins
COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN set +x \
  && /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt

# list installed software versions
RUN set +x \
  && echo ''; echo '*** INSTALLED SOFTWARE VERSIONS ***';echo ''; \
  cat /etc/*release; python3 --version; \
  docker version; git --version; jq --version; \
  kubectl version; gcloud version; istioctl version; echo '';

RUN set +x \
  && apt-get clean

# set timezone to America/New_York
RUN set +x \
  && cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
  && echo "America/New_York" >  /etc/timezone \
  && date

# drop back to the regular jenkins user - good practice
USER jenkins
