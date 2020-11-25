#!/bin/bash -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SH_DIR="${ROOT_DIR}/sh"
source "${SH_DIR}/build_tagged_images.sh"
source "${SH_DIR}/containers_down.sh"
source "${SH_DIR}/containers_up.sh"
source "${SH_DIR}/ip_address.sh"
source "${SH_DIR}/echo_versioner_env_vars.sh"
export $(echo_versioner_env_vars)

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
html_demo()
{
  build_tagged_images
  containers_up api-demo
  api_demo
  if [ "${1:-}" == '--no-browser' ]; then
    containers_down
  else
    open "http://$(ip_address):80/dashboard/show?id=FxWwrr&auto_refresh=true&minute_columns=true"
  fi
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
api_demo()
{
  echo
  echo API
  curl_json_body_200 alive
  curl_json_body_200 ready
  curl_json_body_200 sha
  echo
  curl_200           assets/app.css 'Content-Type: text/css'
  #echo 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
  #cat $(log_filename)
  #Must not contain SassC::SyntaxError:
  #echo 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
  curl_200           assets/app.js  'Content-Type: application/javascript'
  #echo 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
  #cat $(log_filename)
  #Must not contain Uglifier::Error
  #echo 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
  echo
  curl_200           show?id=FxWwrr  dashboard-page
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
      "http://${IP_ADDRESS}:$(port)/${route}" \
      > "$(log_filename)" 2>&1

  grep --quiet 200 "$(log_filename)" # eg HTTP/1.1 200 OK
  local -r result=$(tail -n 1 "$(log_filename)")
  echo "$(tab)GET ${route} => 200 ...|${result}"
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
      "http://${IP_ADDRESS}:$(port)/${route}" \
      > "$(log_filename)" 2>&1

  grep --quiet 200 "$(log_filename)" # eg HTTP/1.1 200 OK
  local -r result=$(grep "${pattern}" "$(log_filename)" | head -n 1)
  echo "$(tab)GET ${route} => 200 ...|${result}"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
port() { echo -n "${CYBER_DOJO_DASHBOARD_PORT}"; }

tab() { printf '\t'; }
log_filename() { echo -n /tmp/dashboard.log; }

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
html_demo "$@"
