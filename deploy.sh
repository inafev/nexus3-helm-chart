#!/bin/bash -x

# Creation of nexus PVC
#kubectl apply -f nexus-pvc.yaml
kubectl get pvc

# Add Helm repo
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo add choerodon https://openchart.choerodon.com.cn/choerodon/c7n
helm repo update
helm repo list

# helm
helm list

# Setting up Nginx Ingress Controller
helm install nginx-ingress stable/nginx-ingress --set controller.publishService.enabled=true

# Setting up external-dns
helm install external-dns stable/external-dns -f externaldns-values.yaml

# Setting up Nexus3
#helm install nexus3 ./nexus3 --set nodeSelector."kubernetes\\.io/hostname=pool-ztospgm8l-3cl8p"
helm install nexus3 ./nexus3 

# helm
helm list
