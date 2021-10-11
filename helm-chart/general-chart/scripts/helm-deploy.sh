#!/bin/sh

<<DOC
  .SYNOPSIS
    To update project with helm upgrade command
  .POSITION_PARAMETER EKS_CLUSTER_NAME
    EKS cluster name
  .POSITION_PARAMETER PROJECT
    Project name
  .POSITION_PARAMETER APP
    Application name
  .POSITION_PARAMETER ENV
    Environment name
  .POSITION_PARAMETER VERSION
    Release version
  .POSITION_PARAMETER OPTION
    Helm option ex. --dry-run, --debug
  .Notes
    Need to do these step before run the script
      - Set AWS credentials
      - Provide environment config (and secret)
      - Install realpath for mac (brew install coreutils)
  .EXAMPLE
    ./helm-deploy.sh docker-desktop project app dev latest
DOC

# e: immediately exit if error
# u: exit if refer to non existing variable
# o: return error code of any sub command in pipeline
set -euo pipefail

HELMDIR="$(dirname $(realpath "$0"))/.."

EKS_CLUSTER_NAME=$1
PROJECT=$2
APP=$3
ENV=$4
VERSION=$5
if [ $# -ge 6  ]; then
  OPTION="${@:6}"
else
  OPTION=""
fi
echo $OPTION

# aws eks --region "ap-southeast-1" update-kubeconfig --name ${EKS_CLUSTER_NAME}
kubectl config use-context $EKS_CLUSTER_NAME
kubectl config current-context

NAMESPACE=${PROJECT}-${ENV}
RELEASE_NAME=${APP}-${ENV}

echo "helm upgrade --install $RELEASE_NAME --namespace $NAMESPACE"
helm upgrade --install $RELEASE_NAME --namespace $NAMESPACE \
--wait --timeout 2m \
--create-namespace \
-f $HELMDIR/values.yaml \
-f $HELMDIR/values/$APP/values.yaml \
-f $HELMDIR/values/$APP/$ENV.yaml \
--set env=$ENV \
--set project=$PROJECT \
--set app=$APP \
--set container.version=$VERSION \
$OPTION $HELMDIR

echo "==== Resources ==="
helm get manifest $RELEASE_NAME --namespace $NAMESPACE | kubectl get -f -

echo "==== Running images ==="
kubectl get pods --namespace $NAMESPACE -o jsonpath="{.items[*].spec.containers[*].image}"
