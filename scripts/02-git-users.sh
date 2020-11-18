#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
SRC_DIR="$(cd "${SCRIPT_DIR}"; pwd -P)"

GIT_PROTOCOL=${GIT_PROTOCOL:-http}
GIT_HOST=${GIT_HOST:-gogs.tools:3000}
GIT_CRED_USERNAME=${GIT_CRED_USERNAME:-toolkit}
GIT_CRED_PASSWORD=${GIT_CRED_PASSWORD:-toolkit}
GIT_URL="${GIT_PROTOCOL}://${GIT_HOST}"
ACCESS_TOKEN=$(curl -s -u "${GIT_CRED_USERNAME}:${GIT_CRED_PASSWORD}" "${GIT_URL}/api/v1/users/GIT_CRED_USERNAME/tokens" | jq -r '.[0].sha1')

COUNT_USERS=${COUNT_USERS:-15}
for (( c=1; c<=COUNT_USERS; c++ )); do
  echo "Creating user user${c} on Git Server ${GIT_URL}"
  curl -v -X POST -H "Authorization: token ${ACCESS_TOKEN}" -H "Content-Type: application/json" -d "{ \"username\": \"user${c}\", \"password\": \"user${c}\", \"email\": \"user${c}@cloudnativetoolkit.dev\" }" "${GIT_URL}/api/v1/admin/users"
done
