#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
SRC_DIR="$(cd "${SCRIPT_DIR}"; pwd -P)"

TOOLKIT_NAMESPACE=${TOOLKIT_NAMESPACE:-tools}
GIT_PROTOCOL="https"
GIT_HOST=$(oc get route -n ${TOOLKIT_NAMESPACE} gogs --template='{{.spec.host}}')
GIT_URL="${GIT_PROTOCOL}://${GIT_HOST}"
GIT_NAME="Git"

oc patch consolelink toolkit-sourcecontrol --type merge -p "{\"spec\": {\"href\": \"${GIT_URL}\", \"text\": \"${GIT_NAME}\"}}"