#!/usr/bin/env bash

set -uo pipefail

TOOLKIT_NAMESPACE=${TOOLKIT_NAMESPACE:-tools}
GIT_PROTOCOL=${GIT_PROTOCOL:-http}
GIT_HOST=$(oc get route -n ${TOOLKIT_NAMESPACE} gogs --template='{{.spec.host}}')
GIT_URL="${GIT_PROTOCOL}://${GIT_HOST}"
GIT_CRED_USERNAME=${GIT_CRED_USERNAME:-toolkit}
GIT_CRED_PASSWORD=${GIT_CRED_PASSWORD:-toolkit}
ACCESS_TOKEN=$(curl -s -u "${GIT_CRED_USERNAME}:${GIT_CRED_PASSWORD}" "${GIT_URL}/api/v1/users/${GIT_CRED_USERNAME}/tokens" | jq -r '.[0].sha1')
USER_DEMO=${USER_DEMO:-userdemo}
USER_COUNT=${USER_COUNT:-15}
USER_PREFIX=${USER_PREFIX:-user}
TOOLKIT_SECRET=${TOOLKIT_SECRET:-ibm-toolkit-htpasswd}
HTPASSWD_FILENAME=${HTPASSWD_FILENAME:-htpasswd}
# password is the password :-)
HTPASSWD_HASH='$2y$05$.juxXTUzqc5wzUlCcZl1puKGI9YDOLhFV7.HFtYi1GdD.DKG32D0.'
PROJECT_PREFIX=${PROJECT_PREFIX:-project}
TOOLKIT_GROUP=${TOOLKIT_GROUP:-ibm-toolkit-users}

# 01-git-repos
# TODO: remove projectdemo from qa & staging values.yaml 

# 02-git-users
response=$(curl --write-out '%{http_code}' --silent --output /dev/null -X DELETE -H "Authorization: token ${ACCESS_TOKEN}" "${GIT_URL}/api/v1/admin/users/${USER_DEMO}")
if [[ "${response}" == "204" ]]; then
  echo "git user ${USER_DEMO} removed"
elif [[ "${response}" == "404" ]]; then
  echo "git user ${USER_DEMO} not found"
else
  echo "error ${response} removing git user ${USER_DEMO}"
fi

# 10-ocp-users
TMP_DIR=$(mktemp -d)
pushd "${TMP_DIR}"
for (( c=1; c<=USER_COUNT; c++ )); do
  # zero pad ids 1-9
  printf -v id "%02g" ${c}
  # create username and password for each user
  echo "${USER_PREFIX}${id}:${HTPASSWD_HASH}" >> ${HTPASSWD_FILENAME}
done
oc delete secret ${TOOLKIT_SECRET} -n openshift-config 2>/dev/null || true
oc create secret generic ${TOOLKIT_SECRET} -n openshift-config --from-file=htpasswd=${HTPASSWD_FILENAME}
for e in dev qa staging production; do
oc delete project ${PROJECT_PREFIX}demo-${e}
done
popd

# 11-ocp-group=argocd
oc adm groups remove-users argocd-admins ${USER_DEMO}

# 12-ocp-group-toolkit
oc adm groups remove-users ${TOOLKIT_GROUP} ${USER_DEMO}
