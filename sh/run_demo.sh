#!/bin/bash -Ee

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export SH_DIR="${ROOT_DIR}/sh"
source ${SH_DIR}/versioner_env_vars.sh
source ${SH_DIR}/build_images.sh
source ${SH_DIR}/containers_up.sh
source ${SH_DIR}/containers_down.sh
export $(versioner_env_vars)

# - - - - - - - - - - - - - - - - - - - - - - - - - -
run_demo()
{
  local -r TMP_HTML_FILENAME=/tmp/dashboard-demo.html
  docker exec \
    test-differ-client \
      sh -c 'ruby /app/src/html_demo.rb' \
        > ${TMP_HTML_FILENAME}

  open "file://${TMP_HTML_FILENAME}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -
build_tagged_images
containers_up
run_demo
containers_down
