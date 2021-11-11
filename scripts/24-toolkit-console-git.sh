#!/usr/bin/env bash

set -euo pipefail

TOOLKIT_NAMESPACE=${TOOLKIT_NAMESPACE:-tools}
GIT_PROTOCOL="https"
INSTANCE_NAME=${INSTANCE_NAME:-gitea-tools}
GIT_HOST=$(oc get route ${INSTANCE_NAME} -n ${TOOLKIT_NAMESPACE} -o jsonpath='{.spec.host}')
GIT_ORG=${GIT_ORG:-toolkit}
GIT_REPO=${GIT_REPO:-gitops}
GIT_URL="${GIT_PROTOCOL}://${GIT_HOST}"
GIT_URL_OPS="${GIT_PROTOCOL}://${GIT_HOST}/${GIT_ORG}/${GIT_REPO}"
GIT_NAME="Git Dev"
GIT_NAME_OPS="Git Ops"

oc patch consolelink toolkit-sourcecontrol --type merge -p "{\"spec\": {\"href\": \"${GIT_URL}\", \"text\": \"${GIT_NAME}\"}}"

oc apply -f - <<EOF
apiVersion: console.openshift.io/v1
kind: ConsoleLink
metadata:
  annotations:
  labels:
    group: catalyst-tools
    grouping: garage-cloud-native-toolkit
  name: toolkit-gitops
spec:
  applicationMenu:
    imageURL: $(oc get consolelink toolkit-sourcecontrol -o jsonpath='{.spec.applicationMenu.imageURL}')
    section: Cloud-Native Toolkit
  href: ${GIT_URL_OPS}
  location: ApplicationMenu
  text: ${GIT_NAME_OPS}
EOF