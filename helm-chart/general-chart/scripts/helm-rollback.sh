#!/bin/sh

<<DOC
  .SYNOPSIS
    To update project with helm upgrade command
  .POSITION_PARAMETER EKS_CLUSTER_NAME
    EKS cluster name
  .POSITION_PARAMETER PROJECT
    Project name
  .POSITION_PARAMETER ENV
    Environment name
  .Notes
    Need to do these step before run the script
      - Set AWS credentials
  .EXAMPLE
    ./helm-rollback.sh common-nonprod price-product-middleware sit
DOC

# e: immediately exit if error
# u: exit if refer to non existing variable
# o: return error code of any sub command in pipeline
set -euo pipefail

HELMDIR="$(dirname $(realpath "$0"))/.."

EKS_CLUSTER_NAME=$1
PROJECT=$2
ENV=$3

NAMESPACE=${PROJECT}-${ENV}
RELEASE_NAME=$NAMESPACE

aws eks --region "ap-southeast-1" update-kubeconfig --name ${EKS_CLUSTER_NAME}
helm rollback $RELEASE_NAME
