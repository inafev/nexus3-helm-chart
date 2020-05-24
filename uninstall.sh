#!/bin/bash -x
helm uninstall nexus3
helm list

#kubectl delete pvc nexus
kubectl get pvc