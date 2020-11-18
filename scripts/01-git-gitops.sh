#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
SRC_DIR="$(cd "${SCRIPT_DIR}"; pwd -P)"

GIT_PROTOCOL=${GIT_PROTOCOL:-http}
GIT_HOST=${GIT_HOST:-gogs.tools:3000}
GIT_ORG=${GIT_ORG:-toolkit}
GIT_REPO=${GIT_REPO:-gitops}
GIT_CRED_USERNAME=${GIT_CRED_USERNAME:-toolkit}
GIT_CRED_PASSWORD=${GIT_CRED_PASSWORD:-toolkit}
GIT_URL="${GIT_PROTOCOL}://${GIT_CRED_USERNAME}:${GIT_CRED_PASSWORD}@${GIT_HOST}/${GIT_ORG}/${GIT_REPO}.git"

TMP_DIR=$(mktemp -d)
pushd "${TMP_DIR}"



cp -r "${SRC_DIR}/../gitops/" .
git init
git add .
git commit -m "first commit"
git remote add origin ${GIT_URL}
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



