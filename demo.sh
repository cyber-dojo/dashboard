#!/usr/bin/env bash
set -Eeu

export MY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPTS_DIR="${MY_DIR}/sh"

source "${SCRIPTS_DIR}/lib.sh"
source "${SCRIPTS_DIR}/build_images.sh"
source "${SCRIPTS_DIR}/config.sh"
source "${SCRIPTS_DIR}/containers_down.sh"
source "${SCRIPTS_DIR}/containers_up_healthy_and_clean.sh"
source "${SCRIPTS_DIR}/copy_in_saver_test_data.sh"
#source "${SCRIPTS_DIR}/create_docker_compose_yml.sh"

export $(docker run --rm cyberdojo/versioner)

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
curl_smoke_test()
{
  echo curl log in $(log_filename)
  rm -rf $(log_filename) || true

  curl_json_body_200 alive
  curl_json_body_200 ready
  curl_json_body_200 sha

  curl_plain_200 assets/app.css 'Content-Type: text/css'
  curl_plain_200 assets/app.js 'Content-Type: application/javascript'
  curl_plain_200 show/FxWwrr dashboard-page
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
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

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
curl_json_body_200()
{
  local -r route="${1}"  # eg ready
  echo -n "GET ${route} => 200 ...|"
  if curl_json "${route}" && grep --quiet 200 "$(log_filename)"; then
    local -r result=$(tail -n 1 "$(log_filename)")
    echo "${result}"
  else
    echo FAILED
    echo
    cat "$(log_filename)"
    exit 42
  fi
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
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

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
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

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
log_filename() { echo -n /tmp/dashboard.log; }

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
#create_docker_compose_yml
build_images server
build_images client
build_images nginx
docker compose up --detach nginx
server_up_healthy_and_clean $(server_name)
copy_in_saver_test_data
curl_smoke_test
if [ "${1:-}" == '--no-browser' ]; then
  containers_down
else
  open "http://localhost/dashboard/show/REf1t8?auto_refresh=true&minute_columns=true"
  open "http://localhost/dashboard/show/FxWwrr?auto_refresh=true&minute_columns=true"
  open "http://localhost/dashboard/show/LyQpFr?auto_refresh=true&minute_columns=true"
fi
