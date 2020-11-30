#!/bin/bash -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SH_DIR="${ROOT_DIR}/sh"

source "${SH_DIR}/build_tagged_images.sh"
source "${SH_DIR}/containers_down.sh"
source "${SH_DIR}/containers_up_healthy_and_clean.sh"
source "${SH_DIR}/copy_in_saver_test_data.sh"
source "${SH_DIR}/ip_address.sh"
source "${SH_DIR}/remove_old_images.sh"

source "${SH_DIR}/echo_versioner_env_vars.sh"
export $(echo_versioner_env_vars)

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
curl_smoke_test()
{
  curl_json_body_200 alive
  curl_json_body_200 ready
  curl_json_body_200 sha
  echo

  curl_200           assets/app.css 'Content-Type: text/css'
  #echo 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
  #cat $(log_filename)
  #Must not contain SassC::SyntaxError:
  #echo 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
  echo

  curl_200           assets/app.js  'Content-Type: application/javascript'
  #echo 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
  #cat $(log_filename)
  #Must not contain Uglifier::Error
  #echo 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
  echo

  curl_200           show/FxWwrr  dashboard-page
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
      "http://$(ip_address):$(port)/${route}" \
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
      "http://$(ip_address):$(port)/${route}" \
      > "$(log_filename)" 2>&1

  grep --quiet 200 "$(log_filename)" # eg HTTP/1.1 200 OK
  local -r result=$(grep "${pattern}" "$(log_filename)" | head -n 1)
  echo "GET ${route} => 200 ...|${result}"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
port() { echo -n "${CYBER_DOJO_DASHBOARD_PORT}"; }
log_filename() { echo -n /tmp/dashboard.log; }

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
remove_old_images
build_tagged_images
augmented_docker_compose up --detach nginx
server_up_healthy_and_clean
copy_in_saver_test_data
curl_smoke_test
if [ "${1:-}" == '--no-browser' ]; then
  containers_down
else
  #open "http://$(ip_address)/dashboard/show/REf1t8?auto_refresh=true&minute_columns=true"
  #open "http://$(ip_address)/dashboard/show/FxWwrr?auto_refresh=true&minute_columns=true"
  open "http://$(ip_address)/dashboard/show/LyQpFr?auto_refresh=true&minute_columns=true"
fi
