#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
SRC_DIR="$(cd "${SCRIPT_DIR}"; pwd -P)"

TOOLKIT_NAMESPACE=${TOOLKIT_NAMESPACE:-tools}
GIT_PROTOCOL=${GIT_PROTOCOL:-http}
GIT_HOST=$(oc get route -n ${TOOLKIT_NAMESPACE} gogs --template='{{.spec.host}}')
GIT_URL="${GIT_PROTOCOL}://${GIT_HOST}"
GIT_ORG=${GIT_ORG:-toolkit}
GIT_REPO=${GIT_REPO:-gitops}
GIT_CRED_USERNAME=${GIT_CRED_USERNAME:-toolkit}
GIT_CRED_PASSWORD=${GIT_CRED_PASSWORD:-toolkit}
GIT_GITOPS_URL="${GIT_PROTOCOL}://${GIT_CRED_USERNAME}:${GIT_CRED_PASSWORD}@${GIT_HOST}/${GIT_ORG}/${GIT_REPO}.git"
ACCESS_TOKEN=$(curl -s -u "${GIT_CRED_USERNAME}:${GIT_CRED_PASSWORD}" "${GIT_URL}/api/v1/users/${GIT_CRED_USERNAME}/tokens" | jq -r '.[0].sha1')


echo "creating gitops repo ${GIT_ORG}/${GIT_REPO}.git"
curl -X POST -H "Authorization: token ${ACCESS_TOKEN}" -H "Content-Type: application/json" -d "{ \"name\": \"${GIT_REPO}\" }" "${GIT_URL}/api/v1/admin/users/${GIT_ORG}/repos"


TMP_DIR=$(mktemp -d)
pushd "${TMP_DIR}"

cp -r "${SRC_DIR}/../gitops/" .
git init
git config --local user.email "toolkit@cloudnativetoolkit.dev"
git config --local user.name "IBM Cloud Native Toolkit"
git add .
git commit -m "first commit"
git remote add origin ${GIT_GITOPS_URL}
git push -u origin master

git checkout --orphan staging
echo "This is the staging environment" > README.md
git add README.md
git commit -m "first commit for staging"
git push origin staging

git checkout -b qa
echo "This is the qa environment" > README.md
git add README.md
git commit -m "first commit for qa"
git push origin qa

popd


echo "creating code patterns"
GIT_REPOS="https://github.com/IBM/template-go-gin,app \
           https://github.com/IBM/template-node-react,node-react \
           https://github.com/IBM/template-node-angular,node-angular \
           https://github.com/IBM/template-graphql-typescript,graphql-typescript \
           https://github.com/IBM/template-node-typescript,node-typescript \
           https://github.com/IBM/template-java-spring,java-spring \
           https://github.com/IBM/template-go-gin,go-gin \
           https://github.com/ibm-garage-cloud/inventory-management-svc-solution,inventory-management-svc-solution \
           https://github.com/ibm-garage-cloud/inventory-management-bff-solution,inventory-management-bff-solution \
           https://github.com/ibm-garage-cloud/inventory-management-ui-solution,inventory-management-ui-solution"


for i in ${GIT_REPOS}; do
IFS=","
set $i
echo "snapshot git repo $1 into $2"
TMP_DIR=$(mktemp -d)
pushd "${TMP_DIR}"

echo "Creating repo for ${GIT_HOST}/${GIT_ORG}/$2.git"
curl -X POST -H "Authorization: token ${ACCESS_TOKEN}" -H "Content-Type: application/json" -d "{ \"name\": \"${2}\" }" "${GIT_URL}/api/v1/admin/users/${GIT_ORG}/repos"

git clone --depth 1 --no-tags $1 repo
cd repo
rm -rf .git
git init
git config --local user.email "toolkit@cloudnativetoolkit.dev"
git config --local user.name "IBM Cloud Native Toolkit"
git add .
git commit -m "initial commit"
git remote add downstream ${GIT_PROTOCOL}://${GIT_CRED_USERNAME}:${GIT_CRED_PASSWORD}@${GIT_HOST}/${GIT_ORG}/$2.git
git push downstream master

popd
unset IFS
done


