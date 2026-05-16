#!/usr/bin/env bash
set -Eeu

readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/bin/lib.sh"
source "${ROOT_DIR}/bin/echo_env_vars.sh"
export $(echo_env_vars)

exit_non_zero_unless_installed ruby

readonly traffic_light_count="${1:-3}"
readonly avatar_count="${2:-16}"
ruby "${ROOT_DIR}/bin/create_group_kata.rb" "${traffic_light_count}" "${avatar_count}"
