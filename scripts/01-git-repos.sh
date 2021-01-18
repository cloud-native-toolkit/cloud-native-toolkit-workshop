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
TOOLKIT_GITOPS_PATH_QA=${TOOLKIT_GITOPS_PATH_QA:-qa}
TOOLKIT_GITOPS_PATH_STAGING=${TOOLKIT_GITOPS_PATH_STAGING:-staging}
PROJECT_COUNT=${PROJECT_COUNT:-15}
PROJECT_PREFIX=${PROJECT_PREFIX:-project}
GIT_CRED_USERNAME=${GIT_CRED_USERNAME:-toolkit}
GIT_CRED_PASSWORD=${GIT_CRED_PASSWORD:-toolkit}
GIT_GITOPS_URL="${GIT_PROTOCOL}://${GIT_CRED_USERNAME}:${GIT_CRED_PASSWORD}@${GIT_HOST}/${GIT_ORG}/${GIT_REPO}.git"
ACCESS_TOKEN=$(curl -s -u "${GIT_CRED_USERNAME}:${GIT_CRED_PASSWORD}" "${GIT_URL}/api/v1/users/${GIT_CRED_USERNAME}/tokens" | jq -r '.[0].sha1')

response=$(curl --write-out '%{http_code}' --silent --output /dev/null -H "Authorization: token ${ACCESS_TOKEN}" "${GIT_URL}/api/v1/repos/${GIT_ORG}/${GIT_REPO}")

if [[ "${response}" != "200" ]]; then

echo "creating gitops repo ${GIT_ORG}/${GIT_REPO}.git"
curl -X POST -H "Authorization: token ${ACCESS_TOKEN}" -H "Content-Type: application/json" -d "{ \"name\": \"${GIT_REPO}\" }" "${GIT_URL}/api/v1/admin/users/${GIT_ORG}/repos"


TMP_DIR=$(mktemp -d)
pushd "${TMP_DIR}"

mkdir -p "${TOOLKIT_GITOPS_PATH_QA}"
mkdir -p "${TOOLKIT_GITOPS_PATH_STAGING}"

for i in ${TOOLKIT_GITOPS_PATH_QA} ${TOOLKIT_GITOPS_PATH_STAGING}; do
cat > "${i}/Chart.yaml" <<EOF
apiVersion: v2
version: 0.1.0
name: project-config-helm
description: Chart to configure ArgoCD with the {project-name} project and its applications

dependencies:
- name: argocd-config
  version: 0.16.0
  repository: https://ibm-garage-cloud.github.io/toolkit-charts
EOF
cat > "${i}/values.yaml" <<EOF
global: {}
argocd-config:
  repoUrl: "http://gogs.tools:3000/toolkit/gitops.git"
  project: toolkit-${i}
  applicationTargets:
EOF
for (( c=1; c<=PROJECT_COUNT; c++ )); do
  cat >> "${i}/values.yaml" <<EOF
    - targetRevision: master
      createNamespace: true
      targetNamespace: ${PROJECT_PREFIX}${c}-${i}
      applications:
        - name: ${i}-${PROJECT_PREFIX}${c}-app
          path: ${i}/${PROJECT_PREFIX}${c}/app
          type: helm
EOF
done
done

git init
git config --local user.email "toolkit@cloudnativetoolkit.dev"
git config --local user.name "IBM Cloud Native Toolkit"
echo "Edit [qa/value.yaml](./qa/value.yaml) or [staging/value.yaml](./staging/value.yaml) to add more Apps" > README.md
git add .
git commit -m "first commit"
git remote add origin ${GIT_GITOPS_URL}
git push -u origin master

popd

fi #ends check if repo exits

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
           https://github.com/ibm-garage-cloud/inventory-management-ui-solution,inventory-management-ui-solution \
           https://github.com/ibm-cloud-architecture/appmod-liberty-toolkit"


for i in ${GIT_REPOS}; do
IFS=","
set $i
echo "snapshot git repo $1 into $2"
TMP_DIR=$(mktemp -d)
pushd "${TMP_DIR}"

response=$(curl --write-out '%{http_code}' --silent --output /dev/null -H "Authorization: token ${ACCESS_TOKEN}" "${GIT_URL}/api/v1/repos/${GIT_ORG}/$2")

if [[ "${response}" == "200" ]]; then
  echo "repo already exists ${GIT_HOST}/${GIT_ORG}/$2.git"
  continue
fi

echo "Creating repo for ${GIT_HOST}/${GIT_ORG}/$2.git"
curl -X POST -H "Authorization: token ${ACCESS_TOKEN}" -H "Content-Type: application/json" -d "{ \"name\": \"${2}\" }" "${GIT_URL}/api/v1/admin/users/${GIT_ORG}/repos"

git clone --depth 1 $1 repo
cd repo
rm -rf .git
git init
git config --local user.email "toolkit@cloudnativetoolkit.dev"
git config --local user.name "IBM Cloud Native Toolkit"
git add .
git commit -m "initial commit"
git tag 1.0.0
git remote add downstream ${GIT_PROTOCOL}://${GIT_CRED_USERNAME}:${GIT_CRED_PASSWORD}@${GIT_HOST}/${GIT_ORG}/$2.git
git push downstream master
git push --tags downstream

popd
unset IFS
done


