# Infrastructure as Code - Example

Originally done as an interview task. It can be outdated.

## Tooling stack
* Terraform & Terragrunt (to control environments) - `infrastructure` directory
* Helm, Helmfile, Docker - `k8s-configuration` directory - Helmfile was used only for simplification, I would use GitOps tool like ArgoCD/FluxCD instead
* AWS: IAM, VPC, EKS, RDS Aurora (+RDS IAM), Security Groups, ECR (for Docker Images and Helm Charts), IRSA, ASGs, EIPs
* Kubernetes: CoreDNS, AWS VPC-CNI, kube-proxy, ALB, cluster-autoscaler, metrics-server, HPA for apps, ServiceAccounts, IRSA, auth-aws configmap (now it could be access_entries instead)
* Applications are packed inside `apps` directory

### Tools that could improve this stack
* (Not implemented) ArgoCD/FluxCD - GitOps for better Kubernetes management, instead of Helmfile
* (Not implemented) Atlantis for Terraform - for PR workflow automation and better collaboration

## How TOs

### How to connect to Apps
* http://k8s-sampleapps-1aed292388-1327232125.eu-north-1.elb.amazonaws.com/api/v1/
* http://k8s-sampleapps-1aed292388-1327232125.eu-north-1.elb.amazonaws.com/api/v2/
* It's a one load balancer that is allocated 

### How to connect to AWS

Put it to your `~/.aws/config` or use `aws configure`
```
[profile mycompany]
aws_access_key_id=<id>
aws_secret_access_key=<secret>
region = eu-north-1
output = json
duration_seconds = 43200

```

### How to connect to EKS in eu-north-1
```bash
aws eks update-kubeconfig --name prd-mycompany-01-eu-north-1-apps --role-arn arn:aws:iam::111729354111:role/AmazonEKSAdminRole --region eu-north-1
```

### How to use Terraform
* For example go to `/mycompany-iac/infrastructure/aws/iac/enviroments/production/mycompany-account/eu-north-1/eks` and run `terragrunt init` and then `terragrunt plan` or `terragrunt apply`

### How to push Docker images / Helm Charts to registry 
* Every app has handy Makefile script
* Login to ECR `aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin 111729354111.dkr.ecr.eu-north-1.amazonaws.com`
* Use `make docker-build|docker-push|helm-push`

### How to connect to RDS (from a pod)
```
kubectl exec -it psql -n tooling -- /bin/bash

psql \
   --host=sample-apps.cluster-ro-cjm6ih7n1h7c.eu-north-1.rds.amazonaws.com \
   --port=5432 \
   --username=master_user \
   --password \
   --dbname=sample_apps
```

## Project Structure

```golang
.
├── apps
│   ├── golang
│   │   ├── Dockerfile
│   │   ├── file.p12
│   │   ├── helm
│   │   │   ├── Chart.yaml
│   │   ├── main.go
│   │   └── Makefile
│   └── php
│       ├── config.dev
│       ├── config.prod
│       ├── Dockerfile
│       ├── helm
│       │   ├── Chart.yaml
│       ├── index.php
│       ├── Makefile
├── infrastructure
│   └── aws
│       ├── common_vars.yaml
│       ├── iac
│       │   ├── enviroments
│       │   │   ├── production
│       │   │   └── staging
│       │   └── sources
│       │       ├── ecr
│       │       ├── eks
│       │       ├── service-sample-apps
│       │       ├── shared-infra
│       │       └── vpc
│       └── terragrunt.hcl
└── k8s-configuration
    ├── charts
    │   └── eks-nvme-provisioner
    ├── helmfile.yaml
    ├── releases
    │   ├── common
    │   │   ├── aws-load-balancer-controller
    │   │   ├── cert-manager (not deployed)
    │   │   ├── external-dns (not deployed)
    │   │   └── metrics-server
    │   └── prd-mycompany-01-eu-north-1-apps
    │       ├── cluster-autoscaler
    │       └── nginx-ingress (not deployed)
    └── values
        └── mycompany
            └── production
                ├── eu-north-1
                └── values.yaml
```


# Task

Your task is to:
* Setup EKS on AWS (Stockholm) using Terraform
    * make sure that egress traffic from the cluster is using just one IP address
    * prepare Terraform directory structure knowing that we gonna use multiple regions and 2 environments in each - production and testing
* Dockerize applications
* Expose applications from previous point on single load balancer so that they will be accessible on paths /api/v1/ and /api/v2/
* Configure HPA for those two applications that you have dockerized
* Setup RDS Postgresql/MySQL database using Terraform
* Introduce a mechanism which will spawn a new node in a nodegroup when cluster has insufficient resources* (cluster autoscaler)
* Think about how we can automate adding additional users (Developers) to databases*

## Assumptions, notes & simplifications
* Created separate user for me in AWS and Admins group. For EKS `AmazonEKSAdminRole` is used. For Terraform: `TerragruntDeploymentRole`. 
* Making it easy to iterate for me. To make it easy to run from a single machine with few commands/tools = no CI/CD or ArgoCD which would be another moving part to introduce
* Pushing Docker images and Helm Charts manually to ECR 
* Password for RDS, randomly generated with Terraform - A better way to do it is to use some Secret Manager
* Using HTTP instead of HTTPS - as it was not required
* Using the Host that AWS gives instead of some nice DNS URL
* Using cluster-autoscaler instead of Karpenter as I'm more familiar with it
* Dockerized applications are far from being Production Ready
   * To make it production-ready, follow: https://github.com/kgoralski/microservice-production-readiness-checklist
* Deployed 1 environment for simplicity and to avoid making more costs 

# Presentation
* High level
   * http://k8s-sampleapps-1aed292388-1327232125.eu-north-1.elb.amazonaws.com/api/v1/
   * http://k8s-sampleapps-1aed292388-1327232125.eu-north-1.elb.amazonaws.com/api/v2/
     
```bash
❯ k get pods -A                                                                                    ⎈ prd-mycompany-01-eu-north-1-apps 15:33:36
NAMESPACE     NAME                                            READY   STATUS    RESTARTS   AGE
kube-system   aws-load-balancer-controller-744578f4b7-47q52   1/1     Running   0          24h
kube-system   aws-load-balancer-controller-744578f4b7-8r2dt   1/1     Running   0          24h
kube-system   aws-node-br7rz                                  2/2     Running   0          18h
kube-system   aws-node-lqs9g                                  2/2     Running   0          18h
kube-system   cluster-autoscaler-745c749dc9-b9rbv             1/1     Running   0          18h
kube-system   coredns-575f458476-gxh4z                        1/1     Running   0          18h
kube-system   coredns-575f458476-jkvxv                        1/1     Running   0          18h
kube-system   kube-proxy-97n7h                                1/1     Running   0          3d14h
kube-system   kube-proxy-jxnmw                                1/1     Running   0          3d18h
kube-system   metrics-server-5b46fc496c-85gl4                 1/1     Running   0          27h
sample-apps   golang-deployment-5cc97f46fd-hkxf7              1/1     Running   0          24h
sample-apps   php-deployment-7554cfd966-s2xqb                 1/1     Running   0          24h
tooling       psql                                            1/1     Running   0          21h
```

* Apps:
   * https://github.com/kgoralski/infrastructure-as-code-example/tree/main/apps/golang
   * https://github.com/kgoralski/infrastructure-as-code-example/tree/main/apps/php
   * Dockerfiles (_Dockerize provided applications_):
       * https://github.com/kgoralski/infrastructure-as-code-example/blob/main/apps/golang/Dockerfile
       * https://github.com/kgoralski/infrastructure-as-code-example/blob/main/apps/php/Dockerfile
   * Ingress (_Expose applications from previous point on single load balancer so that they will be accessible on paths /api/v1/ and /api/v2/_)
       * Using ALB Ingress and `alb.ingress.kubernetes.io/group.name` annotation. Every app got its ingress object. Could be replaced with Ambassador, AWS App Mesh Ingress Gateway or Contour - something Envoy Based
       * https://github.com/kgoralski/infrastructure-as-code-example/blob/main/apps/golang/helm/templates/ingress.yaml
       * https://github.com/kgoralski/infrastructure-as-code-example/blob/main/apps/php/helm/templates/ingress.yaml 
   * HPA (_Configure HPA for those two applications_) - using only CPU/MEM, would be better to use http request counts, SQS messages count etc. 
       * https://github.com/kgoralski/infrastructure-as-code-example/blob/main/apps/golang/helm/templates/hpa.yaml
       * https://github.com/kgoralski/infrastructure-as-code-example/blob/main/apps/php/helm/templates/hpa.yaml
 * Infrastructure for apps with RDS (_Setup RDS Postgresql/MySQL database using Terraform_)
   * https://github.com/kgoralski/infrastructure-as-code-example/tree/main/infrastructure/aws/iac/sources/service-sample-apps
   * https://github.com/kgoralski/infrastructure-as-code-example/blob/main/infrastructure/aws/iac/sources/service-sample-apps/rds.tf
 * Infrastructure
   * Structuring it with high environment granularity but per service/product in mind to minimize dependencies 
      * https://github.com/kgoralski/infrastructure-as-code-example/tree/main?tab=readme-ov-file#project-structure 
   * VPC https://github.com/kgoralski/infrastructure-as-code-example/tree/main/infrastructure/aws/iac/sources/vpc
   * EKS https://github.com/kgoralski/infrastructure-as-code-example/tree/main/infrastructure/aws/iac/sources/eks
      * _Make sure that egress traffic from the cluster is using just one IP address_
      * One IP per AZ. Private EKS Nodes -> NATs (EIPs) -> Internet Gateway. An alternative could be some Calico/Istio Egress Gateway
      * https://github.com/kgoralski/infrastructure-as-code-example/blob/main/infrastructure/aws/iac/sources/vpc/vpc.tf#L18
      * IRSA https://github.com/kgoralski/infrastructure-as-code-example/blob/main/infrastructure/aws/iac/sources/eks/irsa.tf
   * ECR https://github.com/kgoralski/infrastructure-as-code-example/tree/main/infrastructure/aws/iac/sources/ecr
   * Cluster Autoscaler (_Introduce a mechanism which will spawn a new node in a nodegroup when cluster has insufficient resources*_) https://github.com/kgoralski/infrastructure-as-code-example/blob/main/k8s-configuration/releases/prd-mycompany-01-eu-north-1-apps/cluster-autoscaler/values.yaml.gotmpl

```
self_managed_node_group_defaults = {
    # enable discovery of autoscaling groups by cluster-autoscaler
    autoscaling_group_tags = {
      "k8s.io/cluster-autoscaler/enabled" : true,
      "k8s.io/cluster-autoscaler/${local.name}" : "owned",
    }
  }
```
  
* Think about how we can automate adding additional users (Developers) to databases*
   * RDS IAM with admin and readonly db users and mapping
   * Using Teleport https://goteleport.com/docs/database-access/guides/rds/ or Tailscale or similar
   * Bastion Host (in the past I used some mechanism with user/role mapping in S3 with some BLESS ssh and DB discovery in given AWS account)
   * For other db users probably DB migration could be used 
