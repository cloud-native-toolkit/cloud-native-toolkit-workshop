#!/usr/bin/env bash

set -euo pipefail


TOOLKIT_NAMESPACE=${TOOLKIT_NAMESPACE:-tools}
GIT_PROTOCOL=${GIT_PROTOCOL:-http}
GIT_HOST=$(oc get route -n ${TOOLKIT_NAMESPACE} gogs --template='{{.spec.host}}')
GIT_URL="${GIT_PROTOCOL}://${GIT_HOST}"
GIT_DEFAULT_PASSWORD=${GIT_DEFAULT_PASSWORD:-password}
GIT_CRED_USERNAME=${GIT_CRED_USERNAME:-toolkit}
GIT_CRED_PASSWORD=${GIT_CRED_PASSWORD:-toolkit}
ACCESS_TOKEN=$(curl -s -u "${GIT_CRED_USERNAME}:${GIT_CRED_PASSWORD}" "${GIT_URL}/api/v1/users/${GIT_CRED_USERNAME}/tokens" | jq -r '.[0].sha1')
USER_COUNT=${USER_COUNT:-15}
GIT_ORG=${GIT_ORG:-toolkit}
GIT_REPO=${GIT_REPO:-gitops}
USER_DEMO=${USER_DEMO:-userdemo}


for (( c=1; c<=USER_COUNT; c++ )); do
  # zero pad ids 1-9
  printf -v id "%02g" ${c}
  response=$(curl --write-out '%{http_code}' --silent --output /dev/null -H "Authorization: token ${ACCESS_TOKEN}" "${GIT_URL}/api/v1/users/user${id}")
  if [[ "${response}" == "200" ]]; then
    echo "git user already exists user${id}"
    continue
  fi
  echo "Creating user user${id} on Git Server ${GIT_URL}"
  curl -X POST -H "Authorization: token ${ACCESS_TOKEN}" -H "Content-Type: application/json" -d "{ \"username\": \"user${id}\", \"password\": \"${GIT_DEFAULT_PASSWORD}\", \"email\": \"user${id}@cloudnativetoolkit.dev\" }" "${GIT_URL}/api/v1/admin/users"
  curl -X PUT -H "Authorization: token ${ACCESS_TOKEN}" -H "Content-Type: application/json" "${GIT_URL}/api/v1/repos/${GIT_ORG}/${GIT_REPO}/collaborators/user${id}"
done

# userdemo
response=$(curl --write-out '%{http_code}' --silent --output /dev/null -H "Authorization: token ${ACCESS_TOKEN}" "${GIT_URL}/api/v1/users/${USER_DEMO}")
if [[ "${response}" == "200" ]]; then
  echo "git ${USER_DEMO} already exists "
else
  echo "Creating user ${USER_DEMO} on Git Server ${GIT_URL}"
  curl -X POST -H "Authorization: token ${ACCESS_TOKEN}" -H "Content-Type: application/json" -d "{ \"username\": \"${USER_DEMO}\", \"password\": \"${GIT_DEFAULT_PASSWORD}\", \"email\": \"${USER_DEMO}@cloudnativetoolkit.dev\" }" "${GIT_URL}/api/v1/admin/users"
  curl -X PUT -H "Authorization: token ${ACCESS_TOKEN}" -H "Content-Type: application/json" "${GIT_URL}/api/v1/repos/${GIT_ORG}/${GIT_REPO}/collaborators/${USER_DEMO}"
fi
