#!/bin/sh

<<DOC
  .SYNOPSIS
    To update project with helm upgrade command
  .POSITION_PARAMETER EKS_CLUSTER_NAME
    EKS cluster name
  .POSITION_PARAMETER BU
    Bussiness unit
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
  .EXAMPLE
    ./helm-upgrade.sh common-nonprod common price-middleware price-product-middleware sit latest
DOC

# e: immediately exit if error
# u: exit if refer to non existing variable
# o: return error code of any sub command in pipeline
set -euo pipefail

HELMDIR="$(dirname $(realpath "$0"))/.."

EKS_CLUSTER_NAME=$1
BU=$2
PROJECT=$3
APP=$4
ENV=$5
VERSION=$6
if [ $# -ge 7  ]; then
  OPTION="${@:7}"
else
  OPTION=""
fi
echo $OPTION

aws eks --region "ap-southeast-1" update-kubeconfig --name ${EKS_CLUSTER_NAME}

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
--set bu=$BU \
--set project=$PROJECT \
--set app=$APP \
--set version=$VERSION $OPTION $HELMDIR

helm get manifest $RELEASE_NAME --namespace $NAMESPACE | kubectl get -f -
