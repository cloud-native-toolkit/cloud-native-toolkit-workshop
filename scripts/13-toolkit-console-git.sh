#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
SRC_DIR="$(cd "${SCRIPT_DIR}"; pwd -P)"

TOOLKIT_NAMESPACE=${TOOLKIT_NAMESPACE:-tools}
GOGS_CONSOLE_URL=$(oc get route -n ${TOOLKIT_NAMESPACE} gogs --template='https://{{.spec.host}}')
oc patch consolelink toolkit-sourcecontrol --type merge -p "{\"spec\": {\"href\": \"$GOGS_CONSOLE_URL\"}}"