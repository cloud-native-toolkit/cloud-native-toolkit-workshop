#!/usr/bin/env bash

# This script grants additional users access to the cluster.

# To add additional users to the cluster provide a file with a list of user ids, one per line, 
# and define a variable name ADDITIONAL_USERS_FILE with the name file.
# For example a file named "users.txt" would have the contents:
# adduser1@email.com
# adduser2@email.com

# and set the value of the environment variable as "export ADDITIONAL_USERS_FILE=users.txt"

# Note: For Openshift clusters (ROKS) on IBM Cloud this is their email addresses and must have a 
# prefix of "IAM#".  For example the users.txt file would contain
# IAM#adduser1@email.com
# IAM#adduser2@email.com

# By default the additional users will granted permissions to create new projects.  If you wish to 
# remove that privilidge set the value of variable ADDITIONAL_USERS_SELF_PROVISIONER to 'N'
# For example:
# export ADDITIONAL_USERS_SELF_PROVISIONER=N

set -euo pipefail

ADDITIONAL_USERS_FILE=${ADDITIONAL_USERS_FILE:-}
ADDITIONAL_USERS_SELF_PROVISIONER=${ADDITIONAL_USERS_SELF_PROVISIONER:-Y}
SELF_PROVISIONER_GROUP=${SELF_PROVISIONER_GROUP:-ibm-toolkit-self-provisioner}
TOOLKIT_GROUP=${TOOLKIT_GROUP:-ibm-toolkit-users}
TOOLKIT_GROUPS="${TOOLKIT_GROUP} \
                argocd-admins"


if [[ -f ${ADDITIONAL_USERS_FILE} ]]; then
  if [[ "${ADDITIONAL_USERS_SELF_PROVISIONER}" == "Y" ]]; then
    TOOLKIT_GROUPS+=" ${SELF_PROVISIONER_GROUP}"
    oc get groups ${SELF_PROVISIONER_GROUP} &>/dev/null || oc adm groups new ${SELF_PROVISIONER_GROUP}
    oc adm policy add-cluster-role-to-group self-provisioner ${SELF_PROVISIONER_GROUP}
  fi

  while read user; do
    for group in ${TOOLKIT_GROUPS}; do  
      oc adm groups add-users ${group} ${user}
    done
  done < ${ADDITIONAL_USERS_FILE}
else
  echo "Additional users file not found ${ADDITIONAL_USERS_FILE}"
fi

