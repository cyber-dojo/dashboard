#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/bin/lib.sh"
#source "${SCRIPTS_DIR}/containers_up_healthy_and_clean.sh"
export $(echo_versioner_env_vars)

curl_smoke_test()
{
  echo curl log in $(log_filename)
  rm -rf $(log_filename) || true

  curl_json_body_200 alive
  curl_json_body_200 ready
  curl_json_body_200 sha

  curl_plain_200 assets/app.css 'content-type: text/css'
  curl_plain_200 assets/app.js 'content-type: application/javascript'
  curl_plain_200 show/FxWwrr dashboard-page
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
    exit 42
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
    exit 42
  fi
}

log_filename() { echo -n /tmp/dashboard.log; }

server_port() { echo "${CYBER_DOJO_DASHBOARD_PORT}"; }


demo()
{
  docker compose build --build-arg COMMIT_SHA="${COMMIT_SHA}" server
  docker compose build --build-arg COMMIT_SHA="${COMMIT_SHA}" client
  docker compose build --build-arg COMMIT_SHA="${COMMIT_SHA}" nginx
  docker compose --progress=plain up --detach --no-build --wait --wait-timeout=10 nginx
  docker compose --progress=plain up --detach --no-build --wait --wait-timeout=10 server
  exit_non_zero_unless_started_cleanly
  copy_in_saver_test_data
  curl_smoke_test
  if [ "${1:-}" == '--no-browser' ]; then
    containers_down
  else
    open "http://localhost/dashboard/show/REf1t8?auto_refresh=true&minute_columns=true"
    open "http://localhost/dashboard/show/FxWwrr?auto_refresh=true&minute_columns=true"
    open "http://localhost/dashboard/show/LyQpFr?auto_refresh=true&minute_columns=true"
  fi
}

demo "$@"