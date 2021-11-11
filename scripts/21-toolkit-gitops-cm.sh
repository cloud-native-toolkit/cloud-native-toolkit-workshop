#!/usr/bin/env bash

set -euo pipefail

TOOLKIT_NAMESPACE=${TOOLKIT_NAMESPACE:-tools}
INSTANCE_NAME=${INSTANCE_NAME:-gitea-tools}
TOOLKIT_GITOPS_HOST=$(oc get route ${INSTANCE_NAME} -n ${TOOLKIT_NAMESPACE} -o jsonpath='{.spec.host}')
TOOLKIT_GITOPS_BRANCH=${TOOLKIT_GITOPS_BRANCH:-master}
TOOLKIT_GITOPS_ORG=${TOOLKIT_GITOPS_ORG:-toolkit}
TOOLKIT_GITOPS_REPO=${TOOLKIT_GITOPS_REPO:-gitops}
TOOLKIT_GITOPS_PROTOCOL=${TOOLKIT_GITOPS_PROTOCOL:-https}

oc delete cm gitops-repo -n ${TOOLKIT_NAMESPACE} 2>/dev/null || true

oc create cm gitops-repo \
--from-literal parentdir="bash -c 'echo qa/\$(basename \${NAMESPACE} -dev)'" \
--from-literal host=${TOOLKIT_GITOPS_HOST} \
--from-literal branch=${TOOLKIT_GITOPS_BRANCH} \
--from-literal org=${TOOLKIT_GITOPS_ORG} \
--from-literal repo=${TOOLKIT_GITOPS_REPO} \
--from-literal protocol=${TOOLKIT_GITOPS_PROTOCOL} \
-n ${TOOLKIT_NAMESPACE}

oc label cm gitops-repo group=catalyst-tools -n ${TOOLKIT_NAMESPACE}