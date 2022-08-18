#!/usr/bin/env bash

set -euo pipefail

TOOLKIT_NAMESPACE=${TOOLKIT_NAMESPACE:-tools}
TOOLKIT_GROUP=${TOOLKIT_GROUP:-ibm-toolkit-users}
TOOLKIT_TOOLS_ROLE=${TOOLKIT_TOOLS_ROLE:-ibm-toolkit-view}
TOOLKIT_CRD_ROLE=${TOOLKIT_CRD_ROLE:-ibm-toolkit-crd-view}
USER_COUNT=${USER_COUNT:-15}
USER_PREFIX=${USER_PREFIX:-user}
USER_DEMO=${USER_DEMO:-userdemo}

if [[ "${TOOLKIT_GROUP}" =~ ^system ]]; then
  echo "Group is a system:xx group. Cannot edit."
  exit 0
fi

oc get groups ${TOOLKIT_GROUP} &>/dev/null || oc adm groups new ${TOOLKIT_GROUP}

for (( c=1; c<=USER_COUNT; c++ )); do
  # zero pad ids 1-9
  printf -v id "%02g" ${c}

  oc adm groups add-users ${TOOLKIT_GROUP} ${USER_PREFIX}${id}
done

#userdemo
oc adm groups add-users ${TOOLKIT_GROUP} ${USER_DEMO}
