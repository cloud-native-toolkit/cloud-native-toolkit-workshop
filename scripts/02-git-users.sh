#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
SRC_DIR="$(cd "${SCRIPT_DIR}"; pwd -P)"

TOOLKIT_NAMESPACE=${TOOLKIT_NAMESPACE:-tools}
GIT_PROTOCOL=${GIT_PROTOCOL:-http}
GIT_HOST=$(oc get route -n ${TOOLKIT_NAMESPACE} gogs --template='{{.spec.host}}')
GIT_URL="${GIT_PROTOCOL}://${GIT_HOST}"
GIT_DEFAULT_PASSWORD=${GIT_DEFAULT_PASSWORD:-password}
GIT_CRED_USERNAME=${GIT_CRED_USERNAME:-toolkit}
GIT_CRED_PASSWORD=${GIT_CRED_PASSWORD:-toolkit}
ACCESS_TOKEN=$(curl -s -u "${GIT_CRED_USERNAME}:${GIT_CRED_PASSWORD}" "${GIT_URL}/api/v1/users/${GIT_CRED_USERNAME}/tokens" | jq -r '.[0].sha1')
COUNT_USERS=${COUNT_USERS:-15}


for (( c=1; c<=COUNT_USERS; c++ )); do

  response=$(curl --write-out '%{http_code}' --silent --output /dev/null -H "Authorization: token ${ACCESS_TOKEN}" "${GIT_URL}/api/v1/users/user${c}")
  if [[ "${response}" == "200" ]]; then
    echo "git user already exists user${c}"
    continue
  fi
  echo "Creating user user${c} on Git Server ${GIT_URL}"
  curl -X POST -H "Authorization: token ${ACCESS_TOKEN}" -H "Content-Type: application/json" -d "{ \"username\": \"user${c}\", \"password\": \"${GIT_DEFAULT_PASSWORD}\", \"email\": \"user${c}@cloudnativetoolkit.dev\" }" "${GIT_URL}/api/v1/admin/users"
done
