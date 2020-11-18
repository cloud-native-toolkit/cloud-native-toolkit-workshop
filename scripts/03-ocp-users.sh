#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
SRC_DIR="$(cd "${SCRIPT_DIR}"; pwd -P)"

HTPASSWD_FILENAME=${HTPASSWD_FILENAME:-users.htpasswd}
HTPASSWD_FILE="${SRC_DIR}/../local/${HTPASSWD_FILENAME}"

COUNT_USERS=${COUNT_USERS:-15}

rm "${HTPASSWD_FILE}" || true
for (( c=1; c<=COUNT_USERS; c++ )); do
  FLAGS="-B -b"
  if [[ "${c}" -eq "1" ]]; then
    FLAGS="${FLAGS} -c"
  fi
  htpasswd ${FLAGS} "${HTPASSWD_FILE}" user${c} user${c}
done


