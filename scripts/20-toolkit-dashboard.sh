#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
SRC_DIR="$(cd "${SCRIPT_DIR}"; pwd -P)"

TOOLKIT_NAMESPACE=${TOOLKIT_NAMESPACE:-tools}
TOOLKIT_DASHBOARD_CONFIG=${TOOLKIT_DASHBOARD_CONFIG:-developer-dashboard-config}
TOOLKIT_DASHBOARD_DEPLOY=${TOOLKIT_DASHBOARD_DEPLOY:-dashboard-developer-dashboard}
GIT_PROTOCOL=${GIT_PROTOCOL:-http}
GIT_HOST=$(oc get route -n ${TOOLKIT_NAMESPACE} gogs --template='{{.spec.host}}')
GIT_URL="${GIT_PROTOCOL}://${GIT_HOST}"
GIT_USER=${GIT_USER:-toolkit}
ORGINAL_JSON_URL=${ORGINAL_JSON_URL:-https://raw.githubusercontent.com/ibm-garage-cloud/developer-dashboard/master/public/data/links.json}

GIT_REPOS="https://github.com/IBM/template-node-react,node-react \
           https://github.com/IBM/template-node-angular,node-angular \
           https://github.com/IBM/template-graphql-typescript,graphql-typescript \
           https://github.com/IBM/template-node-typescript,node-typescript \
           https://github.com/IBM/template-java-spring,java-spring \
           https://github.com/IBM/template-go-gin,go-gin \
           https://github.com/ibm-garage-cloud/inventory-management-svc-solution,inventory-management-svc-solution \
           https://github.com/ibm-garage-cloud/inventory-management-bff-solution,inventory-management-bff-solution \
           https://github.com/ibm-garage-cloud/inventory-management-ui-solution,inventory-management-ui-solution \
           https://github.com/ibm-cloud-architecture/appmod-liberty-toolkit,appmod-liberty-toolkit"


TMP_DIR=$(mktemp -d)
pushd "${TMP_DIR}"

# Download json
curl -sL -o links.json ${ORGINAL_JSON_URL}

for i in ${GIT_REPOS}; do
IFS=","
set $i
echo $1 $2
if [[ "$OSTYPE" == "darwin"* ]]; then
  sed -i .bak "s~${1}~${GIT_URL}/${GIT_USER}/${2}~" links.json
else
  sed -i "s~${1}~${GIT_URL}/${GIT_USER}/${2}~" links.json
fi

unset IFS
done

oc delete cm ${TOOLKIT_DASHBOARD_CONFIG} -n ${TOOLKIT_NAMESPACE} 2>/dev/null || true
oc create cm ${TOOLKIT_DASHBOARD_CONFIG} -n ${TOOLKIT_NAMESPACE} --from-file=LINKS_URL_DATA=links.json
oc set env deployment/${TOOLKIT_DASHBOARD_DEPLOY} -c developer-dashboard -n ${TOOLKIT_NAMESPACE} --from=configmap/${TOOLKIT_DASHBOARD_CONFIG}
popd
