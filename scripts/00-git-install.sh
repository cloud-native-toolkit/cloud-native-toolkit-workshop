#!/usr/bin/env bash

set -euo pipefail

TOOLKIT_NAMESPACE=${TOOLKIT_NAMESPACE:-tools}
GIT_CRED_USERNAME=${GIT_CRED_USERNAME:-toolkit}
GIT_CRED_PASSWORD=${GIT_CRED_PASSWORD:-toolkit}

OPERATOR_NAME="gitea-operator"
OPERATOR_NAMESPACE="openshift-operators"
DEPLOYMENT="${OPERATOR_NAME}-controller-manager"
INSTANCE_NAME="gitea-tools"

if [[ $(oc get subscription ${OPERATOR_NAME} -n ${OPERATOR_NAMESPACE} 2> /dev/null) ]]; then
  echo "Gitea operator already installed"
else
  echo "Install gitea operator"
  helm template ${OPERATOR_NAME} gitea-operator --repo "https://lsteck.github.io/toolkit-charts" | kubectl apply --validate=false -f -

  # Wait for Deployment
  count=0
  until kubectl get deployment "${DEPLOYMENT}" -n "${OPERATOR_NAMESPACE}" 1> /dev/null 2> /dev/null ;
  do
    if [[ ${count} -eq 24 ]]; then
      echo "Timed out waiting for deployment/${DEPLOYMENT} in ${OPERATOR_NAMESPACE} to start"
      kubectl get deployment "${DEPLOYMENT}" -n "${OPERATOR_NAMESPACE}" 
      exit 1
    else
      count=$((count + 1))
    fi

    echo "Waiting for deployment/${DEPLOYMENT} in ${OPERATOR_NAMESPACE} to start"
    sleep 10
  done

  if kubectl get deployment "${DEPLOYMENT}" -n "${OPERATOR_NAMESPACE}" 1> /dev/null 2> /dev/null; then
    kubectl rollout status deployment "${DEPLOYMENT}" -n "${OPERATOR_NAMESPACE}"
  fi

  # Wait for Pods
  count=0
  while kubectl get pods -o jsonpath='{range .items[*]}{.status.phase}{"\n"}{end}' -n "${OPERATOR_NAMESPACE}" | grep -q Pending; do
    if [[ ${count} -eq 24 ]]; then
      echo "Timed out waiting for pods in ${OPERATOR_NAMESPACE} to start"
      kubectl get pods -n "${OPERATOR_NAMESPACE}"
      exit 1
    else
      count=$((count + 1))
    fi

    echo "Waiting for all pods in ${NAMESPACE} to start"
    sleep 10
  done
fi


status=$(oc get pods -n ${TOOLKIT_NAMESPACE} -l app=gitea-tools 2> /dev/null)
if [[ "$status" =~ "Running" ]]; then
  echo "Gitea server already installed"
else
  echo "Install Gitea server"

fi


echo "Checking for toolkit admin account"
# Create toolkit admin user if needed.
#GIT_CRED_USERNAME
admin_user=$(oc get secret gitea-tools-access -n tools -o go-template --template="{{.data.username|base64decode}}")
echo ${admin_user}
echo ${GIT_CRED_USERNAME}
if [${GIT_CRED_USERNAME} == ${admin_user}]; then
  echo "toolkit admin account exists"
else
  echo "Creating toolkit admin account"
fi





