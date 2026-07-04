#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/bin/lib.sh"
source "${ROOT_DIR}/bin/echo_env_vars.sh"
exit_non_zero_unless_installed docker
export $(echo_env_vars)

# Each demo runs as its own docker-compose project so this repo's demo can
# run alongside a sibling repo's demo (eg web) without their networks,
# container names or host ports colliding. nginx is published to the host on
# an overridable port; the backend services talk over the project's private
# network. (dashboard is the one exception - curl_smoke_test below curls it
# directly on CYBER_DOJO_DASHBOARD_PORT.) Override these to run a second
# dashboard demo alongside the first, eg:
#   COMPOSE_PROJECT_NAME=dashboard2 CYBER_DOJO_NGINX_HOST_PORT=81 bin/demo.sh
export COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME:-dashboard}"
export CYBER_DOJO_NGINX_HOST_PORT="${CYBER_DOJO_NGINX_HOST_PORT:-80}"

curl_smoke_test()
{
  echo curl log in $(log_filename)
  rm -rf $(log_filename) || true

  curl_json_body_200 alive
  curl_json_body_200 ready
  curl_json_body_200 sha

  local -r GID=$(cat "${ROOT_DIR}/test/data/demo_gid.txt")
  curl_plain_200 "show/${GID}" dashboard-page
  open "http://localhost:${CYBER_DOJO_NGINX_HOST_PORT}/dashboard/show/${GID}?auto_refresh=true&minute_columns=true"
}

curl_json()
{
  local -r route="${1}"  # eg ready
  curl  \
    --data '' \
    --fail \
    --header 'Content-type: application/json' \
    --header 'Accept: application/json' \
    --request GET \
    --silent \
    --verbose \
      "http://localhost:$(server_port)/${route}" \
      > "$(log_filename)" 2>&1
}

curl_json_body_200()
{
  local -r route="${1}"  # eg ready
  echo -n "GET ${route} => 200 ...|"
  if curl_json "${route}" && grep --quiet 200 "$(log_filename)"; then
    local -r result=$(tail -n 1 "$(log_filename)")
    echo "${result} SUCCESS"
  else
    echo FAILED
    echo
    cat "$(log_filename)"
    exit_non_zero
  fi
}

curl_plain()
{
  local -r route="${1}"   # eg dashboard/choose

  curl  \
    --fail \
    --request GET \
    --silent \
    --verbose \
      "http://localhost:$(server_port)/${route}" \
      > "$(log_filename)" 2>&1
}

curl_plain_200()
{
  local -r route="${1}"   # eg dashboard/choose
  local -r pattern="${2}" # eg Hello
  
  echo -n "GET ${route} => 200 ...|${pattern} "

  if curl_plain "${route}" && grep --quiet 200 "$(log_filename)" && grep --quiet "${pattern}" "$(log_filename)"; then
    echo SUCCESS
  else
    echo FAILED
    echo
    cat "$(log_filename)"
    exit_non_zero
  fi
}

log_filename() { echo -n /tmp/dashboard.log; }

server_port() { echo "${CYBER_DOJO_DASHBOARD_PORT}"; }

# Opens the dashboard for the pre-baked demo cluster (tar-piped into the saver
# by copy_in_saver_test_data). The dashboard resolves the cluster id up and
# renders one tab per child group. Re-bake the cluster with
# bin/create_cluster_data.sh.
open_cluster()
{
  local -r CLUSTER_ID=$(cat "${ROOT_DIR}/test/data/demo_cluster_id.txt")
  echo "Opening cluster ${CLUSTER_ID}"
  open "http://localhost:${CYBER_DOJO_NGINX_HOST_PORT}/dashboard/show/${CLUSTER_ID}?auto_refresh=true&minute_columns=true"
}

demo()
{
  # Tear down only this demo's project (COMPOSE_PROJECT_NAME), leaving any
  # other repo's running demo untouched.
  containers_down
  #docker --log-level=ERROR compose build --build-arg COMMIT_SHA="${COMMIT_SHA}" dashboard
  #docker --log-level=ERROR compose build --build-arg COMMIT_SHA="${COMMIT_SHA}" client

  docker compose \
    --file "$(repo_root)/docker-compose.yml" \
    --file "$(repo_root)/docker-compose.demo.yml" \
    run \
      --detach \
      --service-ports \
      nginx

  copy_in_saver_test_data
  curl_smoke_test
  open_cluster
}

demo "$@"