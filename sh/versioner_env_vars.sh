#!/bin/bash -Eeu

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

# - - - - - - - - - - - - - - - - - - - - - - - -
versioner_env_vars()
{
  docker run --rm cyberdojo/versioner
  echo CYBER_DOJO_DASHBOARD_SERVER_USER=nobody
  echo CYBER_DOJO_DASHBOARD_CLIENT_USER=nobody

  echo CYBER_DOJO_DASHBOARD_IMAGE=cyberdojo/dashboard
  echo CYBER_DOJO_DASHBOARD_PORT=4527

  echo CYBER_DOJO_DASHBOARD_CLIENT_IMAGE=cyberdojo/dashboard-client
  echo CYBER_DOJO_DASHBOARD_CLIENT_PORT=9999

  echo CYBER_DOJO_DASHBOARD_SHA="$(image_sha)"
  echo CYBER_DOJO_DASHBOARD_TAG="$(image_tag)"
}
