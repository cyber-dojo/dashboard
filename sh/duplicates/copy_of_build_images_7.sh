copy_of_build_images_2.sh#!/usr/bin/env bash
set -Eeu

# - - - - - - - - - - - - - - - - - - - - - -
build_images()
{
  if [ "${1:-}" == "" ]; then
    echo
    echo "ERROR: no argument supplied"
    exit_zero_if_show_help --help
  fi
  local -r dil=$(docker image ls --format "{{.Repository}}:{{.Tag}}" --filter=reference="$(server_image)*:*")
  remove_old_images "${dil:-}"
	build_tagged_images "$@"
}

# - - - - - - - - - - - - - - - - - - - - - -
build_tagged_images()
{
  local -r target="${1}"

  docker compose \
    build \
    --build-arg COMMIT_SHA=$(commit_sha) "${target}"

  if [ "${target}" == $(server_name) ]; then
    docker tag $(server_image):$(image_tag) $(server_image):latest
    check_embedded_env_var "$(server_image):latest"
  fi
  if [ "${target}" == $(client_name) ]; then
    docker tag $(client_image):$(image_tag) $(client_image):latest
    check_embedded_env_var "$(client_image):latest"
  fi

  echo
  echo "echo CYBER_DOJO_${SERVICE_NAME}_SHA=$(image_sha)"
  echo "echo CYBER_DOJO_${SERVICE_NAME}_TAG=$(image_tag)"
  echo
}

# - - - - - - - - - - - - - - - - - - - - - -
check_embedded_env_var()
{
  local -r image_name="${1}"
  local -r expected="$(commit_sha)"
  local -r actual="$(sha_in_image ${image_name})"
  echo "Checking SHA env-var is embedded inside ${image_name}"
  if [ "${expected}" == "${actual}" ]; then
    echo It is
  else
    echo "ERROR: unexpected env-var inside image ${image_name}"
    echo "expected: 'SHA=${expected}'"
    echo "  actual: 'SHA=${actual}'"
    exit 42
  fi
}

# - - - - - - - - - - - - - - - - - - - - - -
sha_in_image()
{
  local -r image_name="${1}"
  docker run --rm ${image_name} sh -c 'echo -n ${SHA}'
}

# - - - - - - - - - - - - - - - - - - - - - -
remove_old_images()
{
  echo Removing old images
  local -r dil="${1:-}"
  remove_all_but_latest "$(server_image)" "${dil}"
  remove_all_but_latest "$(client_image)" "${dil}"
}

# - - - - - - - - - - - - - - - - - - - - - -
remove_all_but_latest()
{
  local -r name="${1}"
  local -r docker_image_ls="${2:-}"
  for v in `echo "${docker_image_ls}" | grep "${name}:"`
  do
    if [ "${v}" != "${name}:latest" ]; then
      if [ "${v}" != "${name}:<none>" ]; then
        if [ "${v}" != "${name}:$(image_tag)" ]; then
          docker image rm "${v}"
        fi
      fi
    fi
  done
  docker system prune --force
}

