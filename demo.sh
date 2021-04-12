#!/bin/bash -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPTS_DIR="${ROOT_DIR}/scripts"

source "${SCRIPTS_DIR}/build_images.sh"
source "${SCRIPTS_DIR}/config.sh"
source "${SCRIPTS_DIR}/containers_down.sh"
source "${SCRIPTS_DIR}/containers_up_healthy_and_clean.sh"
source "${SCRIPTS_DIR}/copy_in_saver_test_data.sh"
source "${SCRIPTS_DIR}/create_docker_compose_yml.sh"
source "${SCRIPTS_DIR}/ip_address.sh"

export $(docker run --rm cyberdojo/versioner)

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
curl_smoke_test()
{
  curl_json_body_200 alive
  curl_json_body_200 ready
  curl_json_body_200 sha
  echo

  curl_200 assets/app.css 'Content-Type: text/css'
  cat $(log_filename) | grep 'SassC::SyntaxError:' && exit 42
  echo

  curl_200 assets/app.js 'Content-Type: application/javascript'
  cat $(log_filename) | grep 'Uglifier::Error' && exit 42
  echo

  curl_200 show/FxWwrr dashboard-page
  echo
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
curl_json_body_200()
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
      "http://$(ip_address):$(server_port)/${route}" \
      > "$(log_filename)" 2>&1

  grep --quiet 200 "$(log_filename)" # eg HTTP/1.1 200 OK
  local -r result=$(tail -n 1 "$(log_filename)")
  echo "GET ${route} => 200 ...|${result}"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
curl_200()
{
  local -r route="${1}"   # eg dashboard/choose
  local -r pattern="${2}" # eg Hello
  curl  \
    --fail \
    --request GET \
    --silent \
    --verbose \
      "http://$(ip_address):$(server_port)/${route}" \
      > "$(log_filename)" 2>&1

  grep --quiet 200 "$(log_filename)" # eg HTTP/1.1 200 OK
  local -r result=$(grep "${pattern}" "$(log_filename)" | head -n 1)
  echo "GET ${route} => 200 ...|${result}"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
log_filename() { echo -n /tmp/dashboard.log; }

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
create_docker_compose_yml
build_images server
build_images client
build_images nginx
augmented_docker_compose up --detach nginx
server_up_healthy_and_clean $(server_name)
copy_in_saver_test_data
curl_smoke_test
if [ "${1:-}" == '--no-browser' ]; then
  containers_down
else
  #open "http://$(ip_address)/dashboard/show/REf1t8?auto_refresh=true&minute_columns=true"
  #open "http://$(ip_address)/dashboard/show/FxWwrr?auto_refresh=true&minute_columns=true"
  open "http://$(ip_address)/dashboard/show/LyQpFr?auto_refresh=true&minute_columns=true"
fi
