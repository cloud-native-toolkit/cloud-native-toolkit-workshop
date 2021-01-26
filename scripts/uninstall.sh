#!/usr/bin/env bash

set -uo pipefail


COUNT_USERS=${COUNT_USERS:-15}
USER_PREFIX=${USER_PREFIX:-user}
TOOLKIT_NAMESPACE=${TOOLKIT_NAMESPACE:-tools}
TOOLKIT_SECRET=${TOOLKIT_SECRET:-ibm-toolkit-htpasswd}
TOOLKIT_GROUP=${TOOLKIT_GROUP:-ibm-toolkit-users}
TOOLKIT_TOOLS_ROLE=${TOOLKIT_TOOLS_ROLE:-ibm-toolkit-view}
TOOLKIT_CRD_ROLE=${TOOLKIT_CRD_ROLE:-ibm-toolkit-crd-view}
COUNT_USERS=${COUNT_USERS:-15}
USER_PREFIX=${USER_PREFIX:-user}
PROJECT_PREFIX=${PROJECT_PREFIX:-project}
TOOLKIT_DASHBOARD_CONFIG=${TOOLKIT_DASHBOARD_CONFIG:-developer-dashboard-config}
TOOLKIT_DASHBOARD_DEPLOY=${TOOLKIT_DASHBOARD_DEPLOY:-dashboard-developer-dashboard}
TOOLKIT_GITOPS_APP=${TOOLKIT_GITOPS_APP:-toolkit}
TOOLKIT_GITOPS_PATH_QA=${TOOLKIT_GITOPS_PATH_QA:-qa}
TOOLKIT_GITOPS_PATH_STAGING=${TOOLKIT_GITOPS_PATH_STAGING:-staging}

STARTTIME=$(date +%s)

oc delete all -l app=gogs

oc delete secret ${TOOLKIT_SECRET} -n openshift-configure

# TODO remove htpasswd entry from OAuth cluster

for (( c=1; c<=COUNT_USERS; c++ )); do
  for e in dev qa staging production; do
  oc delete project ${PROJECT_PREFIX}${c}-${e}
  done
done

for (( c=1; c<=COUNT_USERS; c++ )); do
  oc adm groups remove-users argocd-admins ${USER_PREFIX}${c}
done

oc delete group ${TOOLKIT_GROUP}

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