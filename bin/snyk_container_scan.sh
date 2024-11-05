#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/bin/lib.sh"
export $(echo_versioner_env_vars)

snyk container test ${CYBER_DOJO_DASHBOARD_IMAGE}:${CYBER_DOJO_DASHBOARD_TAG} \
      --file="${ROOT_DIR}/Dockerfile" \
      --json-file-output="${ROOT_DIR}/snyk.container.scan.json" \
      --policy-path="${ROOT_DIR}/.snyk"
