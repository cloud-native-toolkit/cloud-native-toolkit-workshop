#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
SRC_DIR="$(cd "${SCRIPT_DIR}"; pwd -P)"

COUNT_USERS=${COUNT_USERS:-15}

for (( c=1; c<=COUNT_USERS; c++ )); do
  oc adm groups add-users argocd-admins user${c}
done


