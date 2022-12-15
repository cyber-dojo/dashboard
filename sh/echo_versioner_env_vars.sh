
# - - - - - - - - - - - - - - - - - - - - - - - -
echo_versioner_env_vars()
{
  local -r sha="$(cd "$(root_dir)" && git rev-parse HEAD)"
  docker run --rm cyberdojo/versioner
  echo CYBER_DOJO_DASHBOARD_SHA="${sha}"
  echo CYBER_DOJO_DASHBOARD_TAG="${sha:0:7}"
}
