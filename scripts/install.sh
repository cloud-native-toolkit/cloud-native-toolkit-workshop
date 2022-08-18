#!/usr/bin/env bash

set -euo pipefail

INSTALL_BRANCH=${INSTALL_BRANCH:-main}
INSTALL_REPO=${INSTALL_REPO:-cloud-native-toolkit/cloud-native-toolkit-workshop}
export TOOLKIT_GROUP=${TOOLKIT_GROUP:-ibm-toolkit-users}

# Run this script like this "curl -sfL workshop.cloudnativetoolkit.dev | sh -"

INSTALL_BASE_URL="https://raw.githubusercontent.com/${INSTALL_REPO}/${INSTALL_BRANCH}/scripts"
INSTALL_SCRIPTS="00-git-install.sh \
                 01-git-repos.sh \
                 02-git-users.sh \
                 10-ocp-users.sh \
                 11-ocp-group-argocd.sh \
                 12-ocp-group-toolkit.sh \
                 13-ocp-group-rbac.sh \
                 20-toolkit-dashboard.sh \
                 21-toolkit-gitops-cm.sh \
                 22-toolkit-gitops-secret.sh \
                 23-toolkit-gitops-project.sh \
                 24-toolkit-console-git.sh"



STARTTIME=$(date +%s)
for i in ${INSTALL_SCRIPTS}; do
 echo "Running script ${INSTALL_BASE_URL}/${i}"
 curl -sL "${INSTALL_BASE_URL}/${i}" | bash
done
DURATION=$(($(date +%s) - $STARTTIME))
echo -e "\033[0;92m Toolkit Workshop install took: $(($DURATION / 60))m$(($DURATION % 60))s \033[0m"
