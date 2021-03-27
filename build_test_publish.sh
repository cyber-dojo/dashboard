#!/bin/bash -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SH_DIR="${ROOT_DIR}/sh"

source "${SH_DIR}/config.sh"
source "${SH_DIR}/create_docker_compose_yml.sh"
source "${SH_DIR}/build_images.sh"
source "${SH_DIR}/containers_down.sh"
source "${SH_DIR}/containers_up_healthy_and_clean.sh"
source "${SH_DIR}/copy_in_saver_test_data.sh"
source "${SH_DIR}/echo_seconds.sh"
source "${SH_DIR}/exit_non_zero_unless_installed.sh"
source "${SH_DIR}/exit_zero_if_build_only.sh"
source "${SH_DIR}/exit_zero_if_show_help.sh"
source "${SH_DIR}/ip_address.sh"
source "${SH_DIR}/on_ci_publish_images.sh"
source "${SH_DIR}/test_in_containers.sh"

export $(docker run --rm cyberdojo/versioner)

#- - - - - - - - - - - - - - - - - - - - - -
t1=$(echo_seconds)

exit_zero_if_show_help "$@"
exit_non_zero_unless_installed docker
exit_non_zero_unless_installed docker-compose

create_docker_compose_yml
build_images
exit_zero_if_build_only "$@"

server_up_healthy_and_clean "$@"
client_up_healthy_and_clean "$@"
copy_in_saver_test_data

test_in_containers "$@"

containers_down
on_ci_publish_images

t2=$(echo_seconds)
echo "Script took $(( t2-t1)) seconds"