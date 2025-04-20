#!/usr/bin/env bash
set -Eeu

echo_base_image()
{
  # This is set to the env-var BASE_IMAGE which is set as a [docker compose build] --build-arg
  # and used the Dockerfile's 'FROM ${BASE_IMAGE}' statement
  # This BASE_IMAGE abstraction is to facilitate the base_image_update.yml workflow
  # which is an work-in-progress experiment to look into automating deployment to the staging environment
  # (https://beta.cyber-dojo.org) of a Dockerfile base-image update (eg to fix snyk vulnerabilities).
  echo_base_image_via_curl
  # echo_base_image_via_code
}

echo_base_image_via_curl()
{
  local -r json="$(curl --fail --silent --request GET https://beta.cyber-dojo.org/dashboard/base_image)"
  echo "${json}" | jq -r '.base_image'
}

echo_base_image_via_code()
{
  # An alternative echo_base_image for local development, or initial base-image upgrade
  local -r tag=759c4e9
  local -r digest=d5f87f343a9f88a598b810c0f02b81db0bb67319701a956aec3577cbd51c1c24
  echo "cyberdojo/sinatra-base:${tag}@sha256:${digest}"
}

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

  if [[ ! -v BASE_IMAGE ]] ; then
    echo BASE_IMAGE="$(echo_base_image)"  # --build-arg
  fi
  if [[ ! -v COMMIT_SHA ]] ; then
    echo COMMIT_SHA="$(image_sha)"  # --build-arg
  fi

  local -r env_filename="$(repo_root)/.env"
  echo "# This file is generated in bin/lib.sh echo_env_vars()" > "${env_filename}"
  echo CYBER_DOJO_DASHBOARD_CLIENT_PORT=9999                   >> "${env_filename}"
  docker run --rm cyberdojo/versioner | grep PORT              >> "${env_filename}"

  # Get identities of all docker-compose.yml dependent services (from versioner)
  docker run --rm cyberdojo/versioner

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

exit_non_zero_if_bad_base_image()
{
  # Called in setup job in .github/workflows/main.yml
  base_image="${1}"
  regex=":[a-z0-9]{7}@sha256:[a-z0-9]{64}$"
  if [[ ${base_image} =~ $regex ]]; then
    echo "PASSED: base_image=${base_image}"
  else
    stderr "base_image=${base_image}"
    stderr "must have a 7-digit short-sha tag and a full 64-digit digest, Eg"
    stderr "  name  : cyberdojo/sinatra-base"
    stderr "  tag   : 559d354"
    stderr "  digest: ddab9080cd0bbd8e976a18bdd01b37b66e47fe83b0db396e65dc3014bad17fd3"
    exit 42
  fi
}

exit_non_zero_unless_file_exists()
{
  local -r filename="${1}"
  if [ ! -f "${filename}" ]; then
    stderr "${filename} does not exist"
    exit 42
  fi
}

exit_non_zero_unless_installed()
{
  for dependent in "$@"
  do
    if ! installed "${dependent}" ; then
      stderr "${dependent} is not installed!"
      exit 42
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
    exit 42
  fi
  echo "${STRIPPED}"
}
