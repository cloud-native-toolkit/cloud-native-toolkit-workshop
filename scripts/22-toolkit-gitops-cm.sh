#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
SRC_DIR="$(cd "${SCRIPT_DIR}"; pwd -P)"

TOOLKIT_NAMESPACE=${TOOLKIT_NAMESPACE:-tools}
TOOLKIT_GITOPS_USERNAME=${TOOLKIT_GITOPS_USERNAME:-toolkit}
TOOLKIT_GITOPS_PASSWORD=${TOOLKIT_GITOPS_PASSWORD:-toolkit}

oc delete secret gitops-cd-secret -n ${TOOLKIT_NAMESPACE} || true

oc create secret -n tools generic gitops-cd-secret \
--from-literal username=${TOOLKIT_GITOPS_USERNAME} \
--from-literal password=${TOOLKIT_GITOPS_PASSWORD} \
-n ${TOOLKIT_NAMESPACE}


oc label secret gitops-cd-secret group=catalyst-tools -n ${TOOLKIT_NAMESPACE}