#!/usr/bin/env bash
set -Eeu

echo_env_vars()
{
  #--------------------
  # Set env-vars for SCSS/JS asset-builder

  local -r asset_builder_port=5135
  local -r asset_env_filename="$(repo_root)/.env.asset_builder"

  echo "# This file is generated in bin/lib.sh echo_env_vars()" > "${asset_env_filename}"
  echo CYBER_DOJO_ASSET_BUILDER_PORT=${asset_builder_port}     >> "${asset_env_filename}"
  echo CYBER_DOJO_ASSET_BUILDER_PORT=${asset_builder_port}
  echo CYBER_DOJO_ASSET_BUILDER_IMAGE=cyberdojo/asset_builder
  echo CYBER_DOJO_ASSET_BUILDER_TAG=2bbe111
  echo CYBER_DOJO_ASSET_BUILDER_CONTAINER_NAME=asset_builder

  #--------------------
  # Set env-vars for this repo

  if [[ ! -v COMMIT_SHA ]] ; then
    echo COMMIT_SHA="$(image_sha)"  # --build-arg
  fi

  local -r env_filename="$(repo_root)/.env"
  echo "# This file is generated in bin/lib.sh echo_env_vars()" > "${env_filename}"
  echo CYBER_DOJO_DASHBOARD_CLIENT_PORT=9999                   >> "${env_filename}"
  run_versioner | grep PORT                                    >> "${env_filename}"

  # Get identities of all docker-compose.yml dependent services (from versioner)
  run_versioner 

  echo CYBER_DOJO_DASHBOARD_SHA="$(image_sha)"
  echo CYBER_DOJO_DASHBOARD_TAG="$(image_tag)"

  echo CYBER_DOJO_DASHBOARD_CLIENT_IMAGE=cyberdojo/dashboard-client
  echo CYBER_DOJO_DASHBOARD_CLIENT_PORT=9999

  echo CYBER_DOJO_DASHBOARD_CLIENT_USER=nobody
  echo CYBER_DOJO_DASHBOARD_SERVER_USER=nobody

  echo CYBER_DOJO_DASHBOARD_CLIENT_CONTAINER_NAME=test_dashboard_client
  echo CYBER_DOJO_DASHBOARD_SERVER_CONTAINER_NAME=test_dashboard_server

  local -r AWS_ACCOUNT_ID=244531986313
  local -r AWS_REGION=eu-central-1
  echo CYBER_DOJO_DASHBOARD_IMAGE="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/dashboard"

  # Here you can add SHA/TAG env-vars for any service whose
  # local repos you have edited, have new git commits in,
  # and have built new images from. Their build scripts
  # finish by printing echo env-var statements you need to
  # add to this function if you want the new images to be
  # part of the dev-loop/demo. For example:
  #
  # echo CYBER_DOJO_SAVER_SHA=491a1d64acc721eaaa1d0338c3bb43fbfadaf78b
  # echo CYBER_DOJO_SAVER_TAG=491a1d6

  echo CYBER_DOJO_SAVER_SHA=d6766949d512390cf3331e563f3f833b8e3e641e
  echo CYBER_DOJO_SAVER_TAG=d676694  
}

run_versioner()
{
  # Hide platform warnings
  docker run --rm cyberdojo/versioner >/tmp/log.stdout 2>/tmp/log.stderr
  cat /tmp/log.stdout
}

image_sha()
{
  git rev-parse HEAD
}

repo_root()
{
  git rev-parse --show-toplevel
}

image_tag()
{
  local -r sha="$(image_sha)"
  echo "${sha:0:7}"
}

containers_down()
{
  docker compose down --remove-orphans --volumes
}

remove_old_images()
{
  echo Removing old images
  local -r dil=$(docker image ls --format "{{.Repository}}:{{.Tag}}" | grep dashboard)
  remove_all_but_latest "${dil}" "${CYBER_DOJO_DASHBOARD_CLIENT_IMAGE}"
  remove_all_but_latest "${dil}" "${CYBER_DOJO_DASHBOARD_IMAGE}"
  remove_all_but_latest "${dil}" cyberdojo/dashboard
}

remove_all_but_latest()
{
  # Keep latest in the cache
  local -r docker_image_ls="${1}"
  local -r name="${2}"
  for image_name in $(echo "${docker_image_ls}" | grep "${name}:")
  do
    if [ "${image_name}" != "${name}:latest" ]; then
      docker image rm "${image_name}"
    fi
  done
  docker system prune --force
}

exit_non_zero_unless_file_exists()
{
  local -r filename="${1}"
  if [ ! -f "${filename}" ]; then
    stderr "${filename} does not exist"
    exit_non_zero
  fi
}

exit_non_zero_unless_installed()
{
  for dependent in "$@"
  do
    if ! installed "${dependent}" ; then
      stderr "${dependent} is not installed!"
      exit_non_zero
    fi
  done
}

installed()
{
  if hash "${1}" &> /dev/null; then
    true
  else
    false
  fi
}

exit_non_zero()
{
  kill -INT $$
}

stderr()
{
  local -r message="${1}"
  >&2 echo "ERROR: ${message}"
}

copy_in_saver_test_data()
{
  local -r SAVER_CID=$(docker ps --filter status=running --format '{{.Names}}' | grep "saver")
  local -r SRC_PATH=${ROOT_DIR}/test/data/cyber-dojo
  local -r DEST_PATH=/cyber-dojo
  # You cannot docker cp to a tmpfs, so tar-piping instead...
  cd ${SRC_PATH} \
    && tar --no-xattrs -c . \
    | docker exec -i ${SAVER_CID} tar x -C ${DEST_PATH}
}

echo_warnings()
{
  local -r SERVICE_NAME="${1}" # {client|server}
  local -r DOCKER_LOG=$(docker logs "${CONTAINER_NAME}" 2>&1)
  # Handle known warnings (eg waiting on Gem upgrade)
  # local -r SHADOW_WARNING="server.rb:(.*): warning: shadowing outer local variable - filename"
  # DOCKER_LOG=$(strip_known_warning "${DOCKER_LOG}" "${SHADOW_WARNING}")

  if echo "${DOCKER_LOG}" | grep --quiet "warning" ; then
    echo "Warnings in ${SERVICE_NAME} container"
    echo "${DOCKER_LOG}"
  fi
}

strip_known_warning()
{
  local -r DOCKER_LOG="${1}"
  local -r KNOWN_WARNING="${2}"
  local -r STRIPPED=$(echo -n "${DOCKER_LOG}" | grep --invert-match -E "${KNOWN_WARNING}")
  if [ "${DOCKER_LOG}" != "${STRIPPED}" ]; then
    echo "Known service start-up warning found: ${KNOWN_WARNING}"
  else
    echo "Known service start-up warning NOT found: ${KNOWN_WARNING}"
    exit_non_zero
  fi
  echo "${STRIPPED}"
}
