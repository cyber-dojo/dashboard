#!/usr/bin/env bash
set -Eeu

readonly TMP_DIR="$(mktemp -d /tmp/dashboard.XXXXXXX)"
remove_tmp_dir() { rm -rf "${TMP_DIR}" > /dev/null; }
trap remove_tmp_dir INT EXIT

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

  # Copy src-path, which contains v0 and v1 katas, to TMP_DIR
  cp -r "${SRC_PATH}" "${TMP_DIR}"

  # Untar saver_data.v2.tgz, which contains .git dirs inside, to TMP_DIR
  pushd "${TMP_DIR}"
  tar -zxf "${ROOT_DIR}/test/data/saver_data.v2.tgz"
  popd

  # tar-pipe v0, v1, v2 katas, from TMP_DIR, into saver container
  cd "${TMP_DIR}/cyber-dojo" \
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
