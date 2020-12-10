#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
SRC_DIR="$(cd "${SCRIPT_DIR}"; pwd -P)"

TOOLKIT_NAMESPACE=${TOOLKIT_NAMESPACE:-tools}
TOOLKIT_GROUP=${TOOLKIT_GROUP:-ibm-toolkit-users}
TOOLKIT_TOOLS_ROLE=${TOOLKIT_TOOLS_ROLE:-ibm-toolkit-view}
TOOLKIT_CRD_ROLE=${TOOLKIT_CRD_ROLE:-ibm-toolkit-crd-view}
COUNT_USERS=${COUNT_USERS:-15}
USER_PREFIX=${USER_PREFIX:-user}

oc get groups ${TOOLKIT_GROUP} &>/dev/null || oc adm groups new ${TOOLKIT_GROUP}

for (( c=1; c<=COUNT_USERS; c++ )); do
  oc adm groups add-users ibm-toolkit ${USER_PREFIX}${c}
done


# Create Cluster Role
oc apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ${TOOLKIT_TOOLS_ROLE}
rules:
- apiGroups:
  - ""
  resources:
  - configmaps
  - secrets
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - tekton.dev
  resources:
  - tasks
  - taskruns
  - pipelines
  - pipelineruns
  - pipelineresources
  - conditions
  - clustertasks
  verbs:
  - get
  - list
  - watch
EOF

# Add ClusterRole to the group
oc adm policy add-role-to-group ${TOOLKIT_TOOLS_ROLE} ${TOOLKIT_GROUP} -n ${TOOLKIT_NAMESPACE}

oc apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ${TOOLKIT_CRD_ROLE}
rules:
- apiGroups:
  - apiextensions.k8s.io
  resources:
  - customresourcedefinitions
  verbs:
  - get
  - list
  - watch
EOF

# Add Cluster Role to view CRDs
oc adm policy add-cluster-role-to-group ${TOOLKIT_CRD_ROLE} ${TOOLKIT_GROUP}


