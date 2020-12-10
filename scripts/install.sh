#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
SRC_DIR="$(cd "${SCRIPT_DIR}"; pwd -P)"

# Run this script like this curl -sL https://raw.githubusercontent.com/ibm-garage-cloud/cloud-native-toolkit-workshops/main/scripts/install.sh | bash

INSTALL_BASE_URL="https://raw.githubusercontent.com/ibm-garage-cloud/cloud-native-toolkit-workshops/main/scripts"
INSTALL_SCRIPTS="00-git-install.sh \
                 01-git-repos.sh \
                 02-git-users.sh \
                 10-ocp-users.sh \
                 11-ocp-group-argocd.sh \
                 12-ocp-group-toolkit.sh \
                 20-toolkit-dashboard.sh \
                 21-toolkit-gitops-secret.sh \
                 22-toolkit-gitops-cm.sh \
                 23-toolkit-gitops-project.sh \
                 24-toolkit-console-git.sh"

for i in ${INSTALL_SCRIPTS}; do
 curl -sL "${INSTALL_BASE_URL}/${i}" | bash
done