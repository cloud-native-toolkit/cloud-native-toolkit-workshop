#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
SRC_DIR="$(cd "${SCRIPT_DIR}"; pwd -P)"

TOOLKIT_NAMESPACE=${TOOLKIT_NAMESPACE:-tools}
GOGS_YAML=${GOGS_YAML:-https://raw.githubusercontent.com/csantanapr/gogs/workshop/gogs-template.yaml}
OCP_DEFAULT_APP_DOMAIN=$(oc get ingresses.config.openshift.io cluster -o template={{.spec.domain}})
GIT_PROTOCOL=${GIT_PROTOCOL:-http}
GIT_HOST=gogs-${TOOLKIT_NAMESPACE}.${OCP_DEFAULT_APP_DOMAIN}
GIT_URL="${GIT_PROTOCOL}://${GIT_HOST}"
GIT_CRED_USERNAME=${GIT_CRED_USERNAME:-toolkit}
GIT_CRED_PASSWORD=${GIT_CRED_PASSWORD:-toolkit}
GOGS_POST_FORM="user_name=${GIT_CRED_USERNAME}&password=${GIT_CRED_PASSWORD}&retype=${GIT_CRED_PASSWORD}&email=toolkit%40cloudnativetoolkit.dev"

oc new-app \
-n ${TOOLKIT_NAMESPACE} \
-f ${GOGS_YAML} \
--param=HOSTNAME=${GIT_HOST}

oc rollout status dc/gogs

echo "creating admin user ${GIT_CRED_USERNAME}"
curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "${GOGS_POST_FORM}" "${GIT_URL}/user/sign_up"

echo "creating access token toolkit for user ${GIT_CRED_USERNAME}"
curl -X POST -H "Content-Type: application/json" -d "{ \"name\": \"toolkit\" }" "${GIT_PROTOCOL}://${GIT_CRED_USERNAME}:${GIT_CRED_PASSWORD}@${GIT_HOST}/api/v1/users/${GIT_CRED_USERNAME}/tokens"