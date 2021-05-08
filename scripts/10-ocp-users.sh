#!/usr/bin/env bash

set -euo pipefail

HTPASSWD_FILENAME=${HTPASSWD_FILENAME:-htpasswd}
TOOLKIT_SECRET=${TOOLKIT_SECRET:-ibm-toolkit-htpasswd}
TOOLKIT_PROVIDER_NAME=${TOOLKIT_PROVIDER_NAME:-ibm-toolkit}
# password is the password :-)
HTPASSWD_HASH='$2y$05$.juxXTUzqc5wzUlCcZl1puKGI9YDOLhFV7.HFtYi1GdD.DKG32D0.'
USER_COUNT=${USER_COUNT:-15}
USER_PREFIX=${USER_PREFIX:-user}
PROJECT_PREFIX=${PROJECT_PREFIX:-project}
USER_DEMO=${USER_DEMO:-userdemo}

TMP_DIR=$(mktemp -d)
pushd "${TMP_DIR}"

for (( c=1; c<=USER_COUNT; c++ )); do
  # zero pad ids 1-9
  printf -v id "%02g" ${c}
  # create username and password for each user
  echo "${USER_PREFIX}${id}:${HTPASSWD_HASH}" >> ${HTPASSWD_FILENAME}
  for e in qa staging production; do
  # create a new namespace for each user and env
  oc new-project ${PROJECT_PREFIX}${id}-${e} || true
  oc adm policy add-cluster-role-to-group system:image-puller "system:serviceaccounts:${PROJECT_PREFIX}${id}-${e}"
  # make user admin of the new project
  oc policy add-role-to-user admin ${USER_PREFIX}${id} -n ${PROJECT_PREFIX}${id}-${e}
  done
done

# userdemo 
# use demo for project id
# create username and password for userdemo
echo "${USER_DEMO}:${HTPASSWD_HASH}" >> ${HTPASSWD_FILENAME}
for e in qa staging production; do
# create a new namespace for each env
oc new-project ${PROJECT_PREFIX}demo-${e} || true
oc adm policy add-cluster-role-to-group system:image-puller "system:serviceaccounts:${PROJECT_PREFIX}demo-${e}"
# make user admin of the new project
oc policy add-role-to-user admin ${USER_DEMO} -n ${PROJECT_PREFIX}demo-${e}
done


oc delete secret ${TOOLKIT_SECRET} -n openshift-config 2>/dev/null || true
oc create secret generic ${TOOLKIT_SECRET} -n openshift-config --from-file=htpasswd=${HTPASSWD_FILENAME}
OAUTH_SPEC=$(oc get OAuth cluster -o json | jq .spec)

if [[ "${OAUTH_SPEC}" == '{}' ]]; then
  echo "No spec configure for OAuth"
oc replace -f - <<EOF
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  annotations:
    release.openshift.io/create-only: "true"
  name: cluster
spec:
  identityProviders:
  - name: ${TOOLKIT_PROVIDER_NAME}
    mappingMethod: claim
    type: HTPasswd
    htpasswd:
      fileData:
        name: ${TOOLKIT_SECRET}
EOF
elif [[ ! "${OAUTH_SPEC}" =~ "${TOOLKIT_SECRET}" ]]; then
  echo "updating OAuth with toolkit users"
  oc patch OAuth cluster --type json -p "[{\"op\":\"add\",\"path\":\"/spec/identityProviders/-\",\"value\":{\"htpasswd\":{\"fileData\":{\"name\":\"${TOOLKIT_SECRET}\"}},\"mappingMethod\":\"claim\",\"name\":\"${TOOLKIT_PROVIDER_NAME}\",\"type\":\"HTPasswd\"} }]"
fi

popd


