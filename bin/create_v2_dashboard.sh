#!/usr/bin/env bash
set -Eeu

readonly MY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${MY_DIR}/lib.sh"
export $(echo_env_vars)

exit_non_zero_unless_installed curl jq

kosli_get()
{
  local -r route="${1}"   # eg languages_start_points/manifests
  curl  \
    --fail \
    --request GET \
    --silent \
    --verbose \
      "http://localhost:80/${route}" 
}

all=$(kosli_get languages-start-points/manifests)
manifests=$(echo "${all}" | jq '.manifests')
names=$(echo "${manifests}" | jq 'keys')
name=$(echo "${names}" | jq '.[2]') # eg "Bash 5.2.37, bats 1.12.0"

echo "${name}"
# Would it be better/faster to make this a python script under test/ ?
# ExternalSaver with new kata_file_create() etc methods can inherit from
# its source/server equivalent.
