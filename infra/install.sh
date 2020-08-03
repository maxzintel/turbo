#!/bin/bash
set -e

# export GIT_COMMIT=$(git log -1 --format=%h)
export BASE_CLUSTER_NAME=$(jq -r '.clusterName' ./tf/terraform.tfvars.json | tr -d "[:cntrl:]")
export REGION=$(jq -r '.region' ./tf/terraform.tfvars.json | tr -d "[:cntrl:]")

# Run Terraform, apply any changes.
terraform init
terraform apply

# Grab cluster name from EKS. NOTE: Will only work if there is only 1 eks cluster in the account.
export FULL_NAME=$(aws eks list-clusters | jq -r '.clusters[0]') # Includes random string.

aws eks --region ${REGION} update-kubeconfig --name ${FULL_NAME}