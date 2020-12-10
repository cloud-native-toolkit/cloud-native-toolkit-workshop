#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
SRC_DIR="$(cd "${SCRIPT_DIR}"; pwd -P)"

TOOLKIT_NAMESPACE=${TOOLKIT_NAMESPACE:-tools}
TOOLKIT_DASHBOARD_CONFIG=${TOOLKIT_DASHBOARD_CONFIG:-developer-dashboard-config}
TOOLKIT_DASHBOARD_DEPLOY=${TOOLKIT_DASHBOARD_DEPLOY:-dashboard-developer-dashboard}

GIT_USER=${GIT_USER:-toolkit}
ORGINAL_JSON_URL=${ORGINAL_JSON_URL:-https://raw.githubusercontent.com/ibm-garage-cloud/developer-dashboard/master/public/data/links.json}

if [[ "$#" -eq 1 ]]; then
  GIT_BASE_URL=$1
else
  echo "git url not passed by parameter"
  echo "getting url from route"
  GIT_BASE_URL="http://$(oc get route -n ${TOOLKIT_NAMESPACE} gogs --template='{{.spec.host}}')"
fi

GIT_REPOS="https://github.com/IBM/template-node-react,node-react \
           https://github.com/IBM/template-node-angular,node-angular \
           https://github.com/IBM/template-graphql-typescript,graphql-typescript \
           https://github.com/IBM/template-node-typescript,node-typescript \
           https://github.com/IBM/template-java-spring,java-spring \
           https://github.com/IBM/template-go-gin,go-gin \
           https://github.com/ibm-garage-cloud/inventory-management-svc-solution,inventory-management-svc-solution \
           https://github.com/ibm-garage-cloud/inventory-management-bff-solution,inventory-management-bff-solution \
           https://github.com/ibm-garage-cloud/inventory-management-ui-solution,inventory-management-ui-solution"


TMP_DIR=$(mktemp -d)
pushd "${TMP_DIR}"

# Download json
curl -sL -o links.json ${ORGINAL_JSON_URL}

for i in ${GIT_REPOS}; do
IFS=","
set $i
echo $1 $2
sed -i .bak "s~${1}~${GIT_BASE_URL}/${GIT_USER}/${2}~" links.json
unset IFS
done

oc delete cm ${TOOLKIT_DASHBOARD_CONFIG} -n ${TOOLKIT_NAMESPACE} || true
oc create cm ${TOOLKIT_DASHBOARD_CONFIG} --from-file=LINKS_URL_DATA=links.json
oc set env deployment/${TOOLKIT_DASHBOARD_DEPLOY} -c developer-dashboard -n ${TOOLKIT_NAMESPACE} --from=configmap/${TOOLKIT_DASHBOARD_CONFIG}
popd
