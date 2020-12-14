#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
SRC_DIR="$(cd "${SCRIPT_DIR}"; pwd -P)"

HTPASSWD_FILENAME=${HTPASSWD_FILENAME:-htpasswd}
TOOLKIT_SECRET=${TOOLKIT_SECRET:-ibm-toolkit-htpasswd}
# password is the password :-)
HTPASSWD_HASH='$2y$05$.juxXTUzqc5wzUlCcZl1puKGI9YDOLhFV7.HFtYi1GdD.DKG32D0.'
COUNT_USERS=${COUNT_USERS:-15}
USER_PREFIX=${USER_PREFIX:-user}

TMP_DIR=$(mktemp -d)
pushd "${TMP_DIR}"

for (( c=1; c<=COUNT_USERS; c++ )); do
  #create username and password for each user
  echo "${USER_PREFIX}${c}:${HTPASSWD_HASH}" >> ${HTPASSWD_FILENAME}
  oc adm policy add-cluster-role-to-group system:image-puller "system:serviceaccounts:${USER_PREFIX}${c}-test"
  oc adm policy add-cluster-role-to-group system:image-puller "system:serviceaccounts:${USER_PREFIX}${c}-qa"
  oc adm policy add-cluster-role-to-group system:image-puller "system:serviceaccounts:${USER_PREFIX}${c}-staging"
  oc adm policy add-cluster-role-to-group system:image-puller "system:serviceaccounts:${USER_PREFIX}${c}-prod"
done

oc delete secret ${TOOLKIT_SECRET} -n openshift-config 2>/dev/null || true
oc create secret generic ${TOOLKIT_SECRET} -n openshift-config --from-file=${HTPASSWD_FILENAME}=${HTPASSWD_FILENAME}
oc get OAuth cluster -o yaml | grep ${TOOLKIT_SECRET}
if [[ $? -ne 0 ]]; then
  echo "updating OAuth with toolkit users"
  oc patch OAuth cluster --type json -p "[{\"op\":\"add\",\"path\":\"/spec/identityProviders/-\",\"value\":{\"htpasswd\":{\"fileData\":{\"name\":\"${TOOLKIT_SECRET}\"}},\"mappingMethod\":\"claim\",\"name\":\"ibm-toolkit\",\"type\":\"HTPasswd\"} }]"
fi

popd


