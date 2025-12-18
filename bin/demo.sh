#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/bin/lib.sh"
exit_non_zero_unless_installed docker
export $(echo_env_vars)

curl_smoke_test()
{
  echo curl log in $(log_filename)
  rm -rf $(log_filename) || true

  curl_json_body_200 alive
  curl_json_body_200 ready
  curl_json_body_200 sha

  curl_plain_200 assets/app.css 'content-type: text/css'
  curl_plain_200 assets/app.js  'content-type: text/javascript'

  curl_plain_200 show/FxWwrr dashboard-page
  open "http://localhost:80/dashboard/show/REf1t8?auto_refresh=true&minute_columns=true"
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

demo()
{
  docker --log-level=ERROR compose build --build-arg COMMIT_SHA="${COMMIT_SHA}" dashboard
  docker --log-level=ERROR compose build --build-arg COMMIT_SHA="${COMMIT_SHA}" client

  docker compose \
    --file "$(repo_root)/docker-compose.yml" \
    run \
      --detach \
      --name test_dashboard_nginx \
      --service-ports \
      nginx

  copy_in_saver_test_data
  curl_smoke_test
}

demo "$@"