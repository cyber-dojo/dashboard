#!/bin/bash -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SH_DIR="${ROOT_DIR}/sh"
source "${SH_DIR}/build_tagged_images.sh"
source "${SH_DIR}/containers_down.sh"
source "${SH_DIR}/containers_up.sh"
source "${SH_DIR}/ip_address.sh"
source "${SH_DIR}/versioner_env_vars.sh"
export $(versioner_env_vars)

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
html_demo()
{
  build_tagged_images
  containers_up api-demo
  api_demo
  if [ "${1:-}" == '--no-browser' ]; then
    containers_down
  else
    open "http://$(ip_address):$(port)/dashboard/show/FxWwrr"
  fi
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
api_demo()
{
  echo
  echo API
  curl_json_body_200 dashboard/alive
  curl_json_body_200 dashboard/ready
  curl_json_body_200 dashboard/sha
  echo
  curl_200           dashboard/assets/app.css 'Content-Type: text/css'
  curl_200           dashboard/assets/app.js 'Content-Type: application/javascript'
  echo
  #curl_200           dashboard/show/FxWwrr  columns
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
  echo "$(tab)GET ${route} => 200 ${result}"
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
  echo "$(tab)GET ${route} => 200 ${result}"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
port() { echo -n "${CYBER_DOJO_NGINX_PORT}"; }

tab() { printf '\t'; }
log_filename() { echo -n /tmp/dashboard.log; }

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
html_demo "$@"
