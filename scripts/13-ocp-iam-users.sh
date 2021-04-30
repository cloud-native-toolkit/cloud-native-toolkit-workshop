#!/usr/bin/env bash

# Use this script to grant access to IBM Cloud users to ROKS cluster
# Update the IAM_USERS list below with the list of user email addresses
# then run the script ./13-ocp-iam-users.sh

set -euo pipefail

TOOLKIT_GROUP=${TOOLKIT_GROUP:-ibm-toolkit-users}
IAM_TOOLKIT_GROUP=${IAM_TOOLKIT_GROUP:-ibm-toolkit-iam-users}
IAM_PREFIX="IAM#"
IAM_USERS="user1@email.com \
           user2@email.com \
           user3@email.com"


STARTTIME=$(date +%s)

oc get groups ${IAM_TOOLKIT_GROUP} &>/dev/null || oc adm groups new ${IAM_TOOLKIT_GROUP}
oc adm policy add-cluster-role-to-group self-provisioner ${IAM_TOOLKIT_GROUP}

for user in ${IAM_USERS}; do
  user=${IAM_PREFIX}${user}
  oc adm groups add-users argocd-admins ${user}
  oc adm groups add-users ${TOOLKIT_GROUP} ${user}
  oc adm groups add-users ${IAM_TOOLKIT_GROUP} ${user}
done
DURATION=$(($(date +%s) - $STARTTIME))
echo -e "\033[0;92m User setup took: $(($DURATION / 60))m$(($DURATION % 60))s \033[0m"