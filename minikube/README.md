# Minikube

Deploy Jenkins to k8s Minikube cluster.

## Deploy Jenkins to Minikube running Istio

```bash
# create cluster
minikube start

kubectl config use-context minikube

# install Istio 0.7.1 without mTLS
kubectl apply -f $ISTIO_HOME/install/kubernetes/istio.yaml

# deploy to local minikube dev environment
sh ./deploy-jenkins-k8s.sh

kubectl get pods -n devops

# get new password
kubectl exec -it jenkins-devops-f57bc8c55-7542r -n devops \
  cat /var/jenkins_home/secrets/initialAdminPassword

# install all default/recommended plug-ins
# install NodeJS, Blue Ocean, GCloud SDK, ThinBackup plug-ins

# copy backup files from container to local drive
kubectl cp \
  devops/jenkins-devops-f57bc8c55-7542r:/tmp/FULL-2018-04-16_02-00 \
  FULL-2018-04-16_02-0/

# mounting in storage volume on Node

mkdir ~/jenkins_home_minikube

minikube ssh
mkdir /tmp/jenkins_home
su -
chmod -R 777 /tmp/jenkins_home/
chown -hR root /tmp/jenkins_home/
chgrp -hR root /tmp/jenkins_home/

# https://stackoverflow.com/a/46097378/580268
# scp ~/Downloads/FULL-2018-04-16_02-0/* docker@192.168.99.100:/tmp/jenkins_home/backups/
# rm -rf /tmp/jenkins_home/*
exit

# chmod 777 ~/jenkins_home_minikube
minikube mount ~/jenkins_home_minikube:/tmp/jenkins_home

# discover URL and port for to connect to Jenkins
# https://istio.io/docs/guides/bookinfo.html
# adjust for minikube ip
export GATEWAY_URL=$(minikube ip):$(kubectl get svc istio-ingress -n istio-system -o 'jsonpath={.spec.ports[0].nodePort}')
echo $GATEWAY_URL

# smoke test
curl $GATEWAY_URL

# kubernetes dashboard
minikube dashboard
```

## Misc. Commands

```bash
brew cask upgrade minikube

minikube version
minikube status
minikube dashboard

minikube get-k8s-versions

eval $(minikube docker-env)
docker ps

kubectl config use-context minikube
kubectl get nodes
kubectl get namespaces
```
