#!/usr/bin/env bash

set -euo pipefail

USER_COUNT=${USER_COUNT:-15}
USER_PREFIX=${USER_PREFIX:-user}

for (( c=1; c<=USER_COUNT; c++ )); do
  # zero pad ids 1-9
  printf -v id "%02g" ${c}
  oc adm groups add-users argocd-admins ${USER_PREFIX}${id}
done


