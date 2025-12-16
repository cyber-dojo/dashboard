#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${ROOT_DIR}/bin/lib.sh"
exit_non_zero_unless_installed docker
export $(echo_env_vars)

create_v2_dashboard()
{
  local -r TYPE=server 
  local -r SERVICE=dashboard
  local -r CONTAINER_NAME="${CYBER_DOJO_DASHBOARD_SERVER_CONTAINER_NAME}"
  local -r USER="${CYBER_DOJO_DASHBOARD_SERVER_USER}"

  #docker compose --progress=plain up --no-build --wait --wait-timeout=10 "${SERVICE}"

  docker exec \
    --user "${USER}" \
    "${CONTAINER_NAME}" \
      sh -c "/dashboard/test/scripts/create_v2_dashboard.rb"
}

create_v2_dashboard 