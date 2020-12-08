#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
SRC_DIR="$(cd "${SCRIPT_DIR}"; pwd -P)"


oc apply -f "${SRC_DIR}/../yaml/system-image-puller.yaml"
