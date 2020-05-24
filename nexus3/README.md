# Helm Chart for nexus3

## Introduction

This [nexus3](https://github.com/sonatype/docker-nexus3) chart installs [sonatype/nexus3](https://hub.docker.com/r/sonatype/nexus3) in a Kubernetes cluster.

## Prerequisites

- Kubernetes cluster 1.10+
- Helm 2.8.0+

## Installation

### Add chart repository

Add chart repository and cache index.

```bash
helm repo add c7n https://openchart.choerodon.com.cn/choerodon/c7n/
helm repo update
```

### Configure the chart

The following items can be configured in `values.yaml` or set via `--set` flag during installation.

#### Configure the way how to expose nexus3 service:

- **Ingress**: The ingress controller must be installed in the Kubernetes cluster.  
- **ClusterIP**: Exposes the service on a cluster-internal IP. Choosing this value makes the service only reachable from within the cluster.
- **NodePort**: Exposes the service on each Node’s IP at a static port (the NodePort). You’ll be able to contact the NodePort service, from outside the cluster, by requesting `NodeIP:NodePort`. 
- **LoadBalancer**: Exposes the service externally using a cloud provider’s load balancer.  

#### Configure the way how to persistent data:

- **Disable**: The data does not survive the termination of a pod.
- **Persistent Volume Claim(default)**: A default `StorageClass` is needed in the Kubernetes cluster to dynamic provision the volumes. Specify another StorageClass in the `storageClass` or set `existingClaim` if you have already existing persistent volumes to use.

#### Configure the other items listed in [configuration](#configuration) section.

### Install the chart

Install the nexus3 helm chart with a release name `my-nexus3`:

```bash
# helm v2
helm install c7n/nexus3 \
  --name my-nexus3 \
  --set expose.ingress.host=nexus3.cluster.local

# helm v3
helm install my-nexus3 c7nw/nexus3 \
  --set expose.ingress.host=nexus3.cluster.local
```

## Uninstallation

To uninstall/delete the `my-nexus3` deployment:

```bash
# helm v2
helm delete --purge my-nexus3

# helm v3
helm uninstall my-nexus3
```

## Configuration

The following table lists the configurable parameters of the nexus3 chart and the default values.

| Parameter                    | Description                                                                                                                                                                                                                                                                   | Default                                  |
| ---------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------- |
| **nexus3**                 |                                                                                                                                                                                                                                                                               |                                          |
| `replicaCount`               | Number of desired pods. This is a pointer to distinguish between explicit zero and not specified.                                                                                                                                                                             | `1`                                      |
| `strategy`                   | The deployment strategy to use to replace existing pods with new ones.                                                                                                                                                                                                        | `RollingUpdate`-`maxUnavailable: 0`      |
| `image.repository`           | Repository for nexus3 image                                                                                                                                                                                                                                                 | `dockerhub.azk8s.cn/sonatype/nexus3` |
| `image.tag`                  | Tag for nexus3 image                                                                                                                                                                                                                                                        | `3.18.1`                        |
| `image.pullPolicy`           | The image pull policy                                                                                                                                                                                                                                                         | `IfNotPresent`                           |
| `annotations`                | Annotations to add to the nexus3 deployment                                                                                                                                                                                                                                 | `{}`                                     |
| `podAnnotations`             | Annotations to add to the nexus3 pod                                                                                                                                                                                                                                        | `{}`                                     |
| `resources`                  | The [resources] to allocate for container                                                                                                                                                                                                                                     | undefined                                |
| `nodeSelector`               | Node labels for pod assignment                                                                                                                                                                                                                                                | `{}`                                     |
| `tolerations`                | Tolerations for pod assignment                                                                                                                                                                                                                                                | `[]`                                     |
| `affinity`                   | Node/Pod affinities                                                                                                                                                                                                                                                           | `{}`                                     |
| `env`                        | The [available options] that can be used to customize your nexus3 installation.                                                                                                                                                                                             | `{}`                                     |
| **Expose**                   |                                                                                                                                                                                                                                                                               |                                          |
| `expose.type`                | The way how to expose the service: `ingress`、`clusterIP`、`loadBalancer` or `nodePort`                                                                                                                                                                                       | `ingress`                                |
| `expose.tls.enabled`         | Enable the tls or not                                                                                                                                                                                                                                                         | `false`                                  |
| `expose.tls.secretName`      | Fill the name of secret if you want to use your own TLS certificate. The secret must contain keys named:`tls.crt` - the certificate, `tls.key` - the private key, `ca.crt` - the certificate of CA.These files will be generated automatically if the `secretName` is not set |                                          |
| `expose.tls.certExpiry`      | Automatically generated self-signed certificate validity period(day)                                                                                                                                                                                                          | `3650`                                   |
| `expose.ingress.host`        | The host of nexus3 service in ingress rule                                                                                                                                                                                                                                  | `nexus3.cluster.local`                 |
| `expose.ingress.annotations` | The annotations used in ingress                                                                                                                                                                                                                                               |                                          |
| `expose.clusterIP.name`      | The name of ClusterIP service                                                                                                                                                                                                                                                 | `Release.Name`                           |
| `expose.clusterIP.port`      | The service port nexus3 listens on when serving with HTTP                                                                                                                                                                                                                   | `80`                                     |
| `expose.nodePort.name`       | The name of NodePort service                                                                                                                                                                                                                                                  | `Release.Name`                           |
| `expose.nodePort.port`       | The service port nexus3 listens on when serving with HTTP                                                                                                                                                                                                                   | `80`                                     |
| `expose.nodePort.nodePort`   | The node port nexus3 listens on when serving with HTTP                                                                                                                                                                                                                      |                                          |
| `expose.loadBalancer.name`   | The name of LoadBalancer service                                                                                                                                                                                                                                              | `Release.Name`                           |
| `expose.loadBalancer.port`   | The service port nexus3Î listens on when serving with HTTP                                                                                                                                                                                                                  | `80`                                     |
| **Persistence**              |                                                                                                                                                                                                                                                                               |                                          |
| `persistence.enabled`        | Enable the data persistence or not                                                                                                                                                                                                                                            | `false`                                  |
| `persistence.resourcePolicy` | Setting it to `keep` to avoid removing PVCs during a helm delete operation. Leaving it empty will delete PVCs after the chart deleted                                                                                                                                         | `keep`                                   |
| `persistence.existingClaim`  | Use the existing PVC which must be created manually before bound, and specify the `subPath` if the PVC is shared with other components                                                                                                                                        |                                          |
| `persistence.storageClass`   | Specify the `storageClass` used to provision the volume. Or the default StorageClass will be used(the default). Set it to `-` to disable dynamic provisioning                                                                                                                 |                                          |
| `persistence.accessMode`     | The access mode of the volume                                                                                                                                                                                                                                                 | `ReadWriteMany`                          |
| `persistence.size`           | The size of the volume                                                                                                                                                                                                                                                        | `5Gi`                                    |

[resources]: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/
[available options]: https://hub.docker.com/r/sonatype/nexus3