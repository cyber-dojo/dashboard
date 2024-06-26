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
source "${SCRIPTS_DIR}/exit_non_zero_unless_installed.sh"
source "${SCRIPTS_DIR}/exit_zero_if_build_only.sh"
source "${SCRIPTS_DIR}/exit_zero_if_show_help.sh"
source "${SCRIPTS_DIR}/test_in_containers.sh"
source "${SCRIPTS_DIR}/echo_versioner_env_vars.sh"
export $(echo_versioner_env_vars)

#- - - - - - - - - - - - - - - - - - - - - -

exit_zero_if_show_help "$@"
exit_non_zero_unless_installed docker

build_images server
exit_zero_if_build_only "$@"
server_up_healthy_and_clean server
#client_up_healthy_and_clean "$@"
copy_in_saver_test_data
test_in_containers server  # no client tests
containers_down
