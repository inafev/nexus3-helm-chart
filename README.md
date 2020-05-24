# Proof of Concept: Nexus3 Chart configuration on Kubernetes. A choerodon/nexus3 Helm 3 Sample Chart on Digital Ocean Kubernetes
- [Introduction](#introduction)
- [Settings Required](#settings-required)
  - [Adding Docker Registry to Nexux3](#adding-docker-registry-to-nexux3)
- [Settings already included in deploy.sh script](#settings-already-included-in-deploysh-script)
  - [External-dns Helm Chart](#external-dns-helm-chart)
  - [Setting up Nginx Ingress Controller](#setting-up-nginx-ingress-controller)
- [Deployment with deploy.sh](#deployment-with-deploysh)
- [Uninstall with uninstall.sh](#uninstall-with-uninstallsh)
- [Helm Commands of Interest](#helm-commands-of-interest)
- [Troubleshooting](#troubleshooting)

## Introduction
- This is a Proof of Concept of [choerodon/nexus3 Helm Chart](https://hub.helm.sh/charts/choerodon/nexus3) with [Helm 3](https://helm.sh/) and [Digital Ocean Kubernetes](https://www.digitalocean.com/products/kubernetes/).
- Based on choerodon/nexus3 version 0.2.0 Helm Chart, with the following modifications:
  - Docker Registry exposed via ingress with self-signed SSL certificate and listening on port 443. Docker Registry needs to be setup manually via Nexus3 UI.
  - securityContext.fsGroup added to comply with kubernetes requirements.
  - Grab the origin files from [hub.helm.sh](https://hub.helm.sh/) or via "helm pull".
- This solution is **not based on Kubernetes Operators.**

## Settings Required 
1. Please do a quick search of **<my_** string to identify the settings that need to be updated accordingly in your specific environment:

```bash
$ grep -ri \<my_ ./*.yaml nexus3/*.yaml
./externaldns-values.yaml:  apiToken: <my_digital_ocean_api_token>
./externaldns-values.yaml:domainFilters: [ '<my_public_dns_domain_name.com>' ]
nexus3/values.yaml:  kubernetes.io/hostname: <my_digital_ocean_worker_node_pool-ztospgm8l-3cl8p>
nexus3/values.yaml:    host: nexus.<my_public_dns_domain_name.com>
nexus3/values.yaml:    repo: docker.<my_public_dns_domain_name.com>
```

2. Replace each setting with your own parameter. For example:
  - Replace **<my_public_dns_domain_name.com>** with **domain-example.com** . I set up a registered domain name that I have for testing purposes.
  - Replace <my_digital_ocean_api_token> with **your_own_digital_ocean_api_token** 
  - Replace <my_digital_ocean_worker_node_pool-ztospgm8l-3cl8p> with your Digital Ocean Kubernetes' worker node.
  - You can find your DO kubernetes credentials in your Digital Ocean account or in *$HOME/.kube/config*.

3. The following DNS names will be created automatically with the corresponding services exposed:
  - **nexus.domain-example.com**  (HTTPS enabled)
  - **docker.domain-example.com** (HTTPS enabled)

### Adding Docker Registry to Nexux3
1. This helm chart has been modified to add docker registry support, exposing the service via kubernetes ingress. Docker Registry needs to be setup manually:
  - [Using Nexus 3 as Your Repository – Part 3: Docker Images](https://blog.sonatype.com/using-nexus-3-as-your-repository-part-3-docker-images)
  - [Create Private Docker Registry (base on Nexus3)](https://qiita.com/leechungkyu/items/86cad0396cf95b3b6973)
  - [Nexus3 Docker Registry](https://help.sonatype.com/repomanager3/formats/docker-registry)
2. Docker Registry is setup with a self-signed certificate. Docker CLI does not accept this unless you set up your docker.domain-example.com as insecure registry:
  - [Test an insecure registry](https://docs.docker.com/registry/insecure/)
  - [Configure docker service to use insecure registry](https://github.com/Juniper/contrail-docker/wiki/Configure-docker-service-to-use-insecure-registry)
3. Testing access: ```docker login docker.domain-example.com```

## Settings already included in deploy.sh script
### External-dns Helm Chart
- [External DNS](https://github.com/helm/charts/tree/master/stable/external-dns) chart needs to be setup in your kubernetes cluster. 
- Already included in **deploy.sh** script. 

```
~/helm$ helm install external-dns stable/external-dns -f externaldns-values.yaml
NAME: external-dns
LAST DEPLOYED: Fri Dec 13 10:28:35 2019
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
** Please be patient while the chart is being deployed **

To verify that external-dns has started, run:

kubectl --namespace=default get pods -l "app.kubernetes.io/name=external-dns,app.kubernetes.io/instance=external-dns"
```

### Setting up Nginx Ingress Controller
- Already included in **deploy.sh** script. 
- Several options: with helm and without helm (see below refs).
- With Helm 3:

```
$ helm install nginx-ingress stable/nginx-ingress --set controller.publishService.enabled=true
NAME: nginx-ingress
LAST DEPLOYED: Wed Jan  1 18:34:02 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The nginx-ingress controller has been installed.
It may take a few minutes for the LoadBalancer IP to be available.
You can watch the status by running 'kubectl --namespace default get services -o wide -w nginx-ingress-controller'

An example Ingress that makes use of the controller:

  apiVersion: extensions/v1beta1
  kind: Ingress
  metadata:
    annotations:
      kubernetes.io/ingress.class: nginx
    name: example
    namespace: foo
  spec:
    rules:
      - host: www.example.com
        http:
          paths:
            - backend:
                serviceName: exampleService
                servicePort: 80
              path: /
    # This section is only required if TLS is to be enabled for the Ingress
    tls:
        - hosts:
            - www.example.com
          secretName: example-tls

If TLS is enabled for the Ingress, a Secret containing the certificate and key must also be provided:

  apiVersion: v1
  kind: Secret
  metadata:
    name: example-tls
    namespace: foo
  data:
    tls.crt: <base64 encoded cert>
    tls.key: <base64 encoded key>
  type: kubernetes.io/tls
```

## Deployment with deploy.sh
Run **./deploy.sh** script.

## Uninstall with uninstall.sh
Run **./uninstall.sh** script.

## Helm Commands of Interest

```bash
helm pull choerodon/nexus3 --version 0.2.0
helm pull choerodon/nexus3 --verify --version 0.2.0
```

## Troubleshooting

```
kubectl logs -f nexus3-nexus3-64fbb5f4f-t7b9d | egrep -i '(error|failure|exception|volume|claim|warning)' --color
```

