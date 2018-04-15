#!/bin/bash

kubectl config use-context minikube

# namespace
kubectl apply -f ./resources/namespace-devops.yaml

# ingress
kubectl apply -f ./resources/ingress-devops.yaml
