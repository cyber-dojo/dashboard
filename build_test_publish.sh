#!/bin/bash -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SH_DIR="${ROOT_DIR}/sh"
source ${SH_DIR}/show_help_if_requested.sh
source ${SH_DIR}/build_tagged_images.sh
source ${SH_DIR}/containers_up.sh
source ${SH_DIR}/test_in_containers.sh
source ${SH_DIR}/containers_down.sh
source ${SH_DIR}/on_ci_publish_images.sh
source ${SH_DIR}/echo_versioner_env_vars.sh
export $(echo_versioner_env_vars)

#- - - - - - - - - - - - - - - - - - - - - -
build_test_publish()
{
  show_help_if_requested "$@"
  build_tagged_images "$@"
  containers_up "$@"
  test_in_containers "$@"
  containers_down
  on_ci_publish_images
}


#- - - - - - - - - - - - - - - - - - - - - -
build_test_publish "$@"
