#!/usr/bin/env bash

set -uo pipefail


USER_PREFIX=${USER_PREFIX:-user}
TOOLKIT_NAMESPACE=${TOOLKIT_NAMESPACE:-tools}
TOOLKIT_SECRET=${TOOLKIT_SECRET:-ibm-toolkit-htpasswd}
TOOLKIT_GROUP=${TOOLKIT_GROUP:-ibm-toolkit-users}
SELF_PROVISIONER_GROUP=${SELF_PROVISIONER_GROUP:-ibm-toolkit-self-provisioner}
ADDITIONAL_USERS_FILE=${ADDITIONAL_USERS_FILE:-}
ADDITIONAL_USERS_SELF_PROVISIONER=${ADDITIONAL_USERS_SELF_PROVISIONER:-Y}
SELF_PROVISIONER_GROUP=${SELF_PROVISIONER_GROUP:-ibm-toolkit-self-provisioner}
TOOLKIT_GROUPS="${TOOLKIT_GROUP} \
                argocd-admins"

TOOLKIT_TOOLS_ROLE=${TOOLKIT_TOOLS_ROLE:-ibm-toolkit-view}
TOOLKIT_CRD_ROLE=${TOOLKIT_CRD_ROLE:-ibm-toolkit-crd-view}
USER_COUNT=${USER_COUNT:-15}
USER_PREFIX=${USER_PREFIX:-user}
PROJECT_PREFIX=${PROJECT_PREFIX:-project}
TOOLKIT_DASHBOARD_CONFIG=${TOOLKIT_DASHBOARD_CONFIG:-developer-dashboard-config}
TOOLKIT_DASHBOARD_DEPLOY=${TOOLKIT_DASHBOARD_DEPLOY:-dashboard-developer-dashboard}
TOOLKIT_GITOPS_APP=${TOOLKIT_GITOPS_APP:-toolkit}
TOOLKIT_GITOPS_PATH_QA=${TOOLKIT_GITOPS_PATH_QA:-qa}
TOOLKIT_GITOPS_PATH_STAGING=${TOOLKIT_GITOPS_PATH_STAGING:-staging}

STARTTIME=$(date +%s)

./uninstall-userdemo.sh

oc delete all -l app=gogs

oc delete secret ${TOOLKIT_SECRET} -n openshift-configure

# TODO remove htpasswd entry from OAuth cluster
# LDS Check with Carlos if the following is correct
oc replace -f - <<EOF
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  annotations:
    release.openshift.io/create-only: "true"
  name: cluster
spec: {}
EOF

for (( c=1; c<=USER_COUNT; c++ )); do
  # zero pad ids 1-9
  printf -v id "%02g" ${c}

  for e in dev qa staging production; do
  oc delete project ${PROJECT_PREFIX}${id}-${e}
  done
done

for (( c=1; c<=USER_COUNT; c++ )); do
  # zero pad ids 1-9
  printf -v id "%02g" ${c}

  oc adm groups remove-users argocd-admins ${USER_PREFIX}${id}
done

if [[ -f ${ADDITIONAL_USERS_FILE} ]]; then
  if [[ "${ADDITIONAL_USERS_SELF_PROVISIONER}" == "Y" ]]; then
    TOOLKIT_GROUPS+=" ${SELF_PROVISIONER_GROUP}"
  fi

  while read user; do
    for group in ${TOOLKIT_GROUPS}; do  
      oc adm groups remove-users ${group} ${user}
    done
  done < ${ADDITIONAL_USERS_FILE}
fi

oc delete group ${TOOLKIT_GROUP}
oc get groups ${SELF_PROVISIONER_GROUP} &>/dev/null || oc delete group ${SELF_PROVISIONER_GROUP}

oc adm policy remove-role-from-group ${TOOLKIT_TOOLS_ROLE} ${TOOLKIT_GROUP} -n ${TOOLKIT_NAMESPACE}
oc delete ClusterRole ${TOOLKIT_TOOLS_ROLE}

oc adm policy remove-cluster-role-from-group ${TOOLKIT_CRD_ROLE} ${TOOLKIT_GROUP}
oc delete ClusterRole ${TOOLKIT_CRD_ROLE}

oc delete cm ${TOOLKIT_DASHBOARD_CONFIG} -n ${TOOLKIT_NAMESPACE}
oc scale --replicas=0 deployment/${TOOLKIT_DASHBOARD_DEPLOY}
oc scale --replicas=1 deployment/${TOOLKIT_DASHBOARD_DEPLOY}

oc delete cm gitops-repo -n ${TOOLKIT_NAMESPACE}
oc delete secret gitops-cd-secret -n ${TOOLKIT_NAMESPACE}
oc delete applications.argoproj.io/${TOOLKIT_GITOPS_APP}-${TOOLKIT_GITOPS_PATH_QA}
oc delete applications.argoproj.io/${TOOLKIT_GITOPS_APP}-${TOOLKIT_GITOPS_PATH_STAGING}


DURATION=$(($(date +%s) - $STARTTIME))
echo -e "\033[0;92m Toolkit Workshop uninstall took: $(($DURATION / 60))m$(($DURATION % 60))s \033[0m"