#!/bin/bash -Eeu

source ${SCRIPTS_DIR}/augmented_docker_compose.sh

# - - - - - - - - - - - - - - - - - - - - - -
build_images()
{
    local -r dil=$(docker image ls --format "{{.Repository}}:{{.Tag}}" --filter=reference="$(server_image)*:*")

    remove_old_images "${dil:-}"

	# Avoid building (even with caches) and rely on
	# /source/ volume-mount in docker-compose.yml
	# for big win on Mac M1

    if [[ "${dil:-}" == *"$(server_image)"* ]]; then
  	  if [[ "${dil:-}" == *"$(client_image)"* ]]; then
          return
  	  fi
    fi

	build_tagged_images
}

# - - - - - - - - - - - - - - - - - - - - - -
build_tagged_images()
{
  augmented_docker_compose \
    build \
    --build-arg COMMIT_SHA=$(commit_sha)

  docker tag $(server_image):$(image_tag) $(server_image):latest
  docker tag $(client_image):$(image_tag) $(client_image):latest

  check_embedded_env_var
  echo
  echo "echo CYBER_DOJO_${SERVICE_NAME}_SHA=$(image_sha)"
  echo "echo CYBER_DOJO_${SERVICE_NAME}_TAG=$(image_tag)"
  echo
}

# - - - - - - - - - - - - - - - - - - - - - -
check_embedded_env_var()
{
  if [ "$(commit_sha)" != "$(sha_in_image)" ]; then
    echo "ERROR: unexpected env-var inside image $(server_image):$(image_tag)"
    echo "expected: 'SHA=$(commit_sha)'"
    echo "  actual: 'SHA=$(sha_in_image)'"
    exit 42
  fi
}

# - - - - - - - - - - - - - - - - - - - - - -
sha_in_image()
{
  docker run --rm $(server_image):$(image_tag) sh -c 'echo -n ${SHA}'
}

# - - - - - - - - - - - - - - - - - - - - - -
remove_old_images()
{
  echo Removing old images
  local -r dil="${1}"
  remove_all_but_latest "${dil}" "$(server_image)"
  remove_all_but_latest "${dil}" "$(client_image)"
}

# - - - - - - - - - - - - - - - - - - - - - -
remove_all_but_latest()
{
  local -r docker_image_ls="${1}"
  local -r name="${2}"
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

