#!/usr/bin/env bash

set -euo pipefail

TOOLKIT_NAMESPACE=${TOOLKIT_NAMESPACE:-tools}
GIT_PROTOCOL="https"
GIT_HOST=$(oc get route -n ${TOOLKIT_NAMESPACE} gogs --template='{{.spec.host}}')
GIT_ORG=${GIT_ORG:-toolkit}
GIT_REPO=${GIT_REPO:-gitops}
GIT_URL="${GIT_PROTOCOL}://${GIT_HOST}"
GIT_URL_OPS="${GIT_PROTOCOL}://${GIT_HOST}/${GIT_ORG}/${GIT_REPO}"
GIT_NAME="Git Dev"
GIT_NAME_OPS="Git Ops"

oc patch consolelink toolkit-sourcecontrol --type merge -p "{\"spec\": {\"href\": \"${GIT_URL}\", \"text\": \"${GIT_NAME}\"}}"
oc delete consolelink ${GIT_NAME_OPS} || true
oc get consolelink toolkit-sourcecontrol -o yaml | sed 's/name: toolkit-sourcecontrol/name: toolkit-gitops/' | sed 's/text: ${GIT_NAME}/text: ${GIT_NAME_OPS}/' | oc apply -f -