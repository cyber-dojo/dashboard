#!/bin/bash -Eeu

# - - - - - - - - - - - - - - - - - - - - - - - -
echo_versioner_env_vars()
{
  # This functions' output must be exported. 
  # See the top of build_test_publish.sh 
  docker run --rm cyberdojo/versioner
  echo CYBER_DOJO_DASHBOARD_SERVER_USER=nobody
  echo CYBER_DOJO_DASHBOARD_CLIENT_USER=nobody

  # CYBER_DOJO_DASHBOARD_IMAGE is in versioner
  echo CYBER_DOJO_DASHBOARD_CLIENT_IMAGE=cyberdojo/dashboard-client

  # CYBER_DOJO_DASHBOARD_PORT is in versioner 
  echo CYBER_DOJO_DASHBOARD_CLIENT_PORT=9999

  echo CYBER_DOJO_DASHBOARD_CLIENT_CONTAINER=test_dashboard_client
  echo CYBER_DOJO_DASHBOARD_SERVER_CONTAINER=test_dashboard_server

  echo CYBER_DOJO_DASHBOARD_SHA="$(image_sha)"
  echo CYBER_DOJO_DASHBOARD_TAG="$(image_tag)"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
image_sha()
{
  echo "$(cd "${ROOT_DIR}" && git rev-parse HEAD)"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
image_tag()
{
  local -r sha="$(image_sha)"
  echo "${sha:0:7}"
}

# - - - - - - - - - - - - - - - - - - - - - -
git_commit_sha()
{
  echo $(cd "${SH_DIR}" && git rev-parse HEAD)
}

# - - - - - - - - - - - - - - - - - - - - - -
image_name()
{
  echo "${CYBER_DOJO_DASHBOARD_IMAGE}"
}

# - - - - - - - - - - - - - - - - - - - - - -
sha_in_image()
{
  docker run --rm $(image_name):$(image_tag) sh -c 'echo -n ${SHA}'
}
