#!/bin/bash
set -e
cd tf/
# export GIT_COMMIT=$(git log -1 --format=%h)
export REGION=$(jq -r '.region' ./terraform.tfvars.json | tr -d "[:cntrl:]")

# Run Terraform, apply any changes.
echo
echo "Now initializing your Terraform backend and applying the changes required..."
echo "This will take about 15 minutes."
echo "."
echo "."
echo "."
terraform init
terraform apply

# Grab cluster name from EKS. NOTE: Will only work if there is only 1 eks cluster in the account.
export FULL_NAME=$(aws eks list-clusters | jq -r '.clusters[0]') # Includes random string.

# Update your kubeconfig to access the new cluster.
echo 
echo "Updating your kubeconfig to access the new cluster."
echo "."
echo "."
echo "."
aws eks --region ${REGION} update-kubeconfig --name ${FULL_NAME}

# Add bitnami charts and install nginx ingress controller.
echo
echo "Adding Bitnami's helm chart for nginx ingress."
echo "."
echo "."
echo "."
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install ingress-nginx-v1 bitnami/nginx

echo
echo "Adding Prometheus Operator for configuring cluster monitoring."
echo "."
echo "."
echo "."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prom prometheus-community/prometheus

echo
echo "Deploying your EFK cluster logging stack."
echo "."
echo "."
echo "."
cd k8s/monitoring
kubectl create -f kube-logging.yaml
kubectl create -f elasticsearch_svc.yaml
kubectl create -f elasticsearch_ss.yaml
kubectl create -f kibana.yaml
kubectl create -f fluentd.yaml
