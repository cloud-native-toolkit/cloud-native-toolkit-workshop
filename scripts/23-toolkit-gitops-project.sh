#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
SRC_DIR="$(cd "${SCRIPT_DIR}"; pwd -P)"

TOOLKIT_NAMESPACE=${TOOLKIT_NAMESPACE:-tools}
TOOLKIT_GITOPS_APP=${TOOLKIT_GITOPS_APP:-toolkit}
TOOLKIT_GITOPS_HOST=${TOOLKIT_GITOPS_HOST:-gogs.tools}
TOOLKIT_GITOPS_PORT=${TOOLKIT_GITOPS_PORT:-3000}
TOOLKIT_GITOPS_BRANCH=${TOOLKIT_GITOPS_BRANCH:-master}
TOOLKIT_GITOPS_PATH_QA=${TOOLKIT_GITOPS_PATH_QA:-qa}
TOOLKIT_GITOPS_PATH_STAGING=${TOOLKIT_GITOPS_PATH_QA:-staging}
TOOLKIT_GITOPS_ORG=${TOOLKIT_GITOPS_ORG:-toolkit}
TOOLKIT_GITOPS_REPO=${TOOLKIT_GITOPS_REPO:-gitops}
TOOLKIT_GITOPS_PROTOCOL=${TOOLKIT_GITOPS_PROTOCOL:-http}

for i in ${TOOLKIT_GITOPS_PATH_QA} ${TOOLKIT_GITOPS_PATH_STAGING}; do
oc apply -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${TOOLKIT_GITOPS_APP}-${i}
  namespace: ${TOOLKIT_NAMESPACE}
spec:
  destination:
    namespace: ${TOOLKIT_NAMESPACE}
    server: 'https://kubernetes.default.svc'
  project: default
  source:
    path: ${i}
    repoURL: ${TOOLKIT_GITOPS_PROTOCOL}://${TOOLKIT_GITOPS_HOST}:${TOOLKIT_GITOPS_PORT}/${TOOLKIT_GITOPS_ORG}/${TOOLKIT_GITOPS_REPO}.git
    targetRevision: ${TOOLKIT_GITOPS_BRANCH}
    helm:
      valueFiles:
        - values.yaml
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF
done



