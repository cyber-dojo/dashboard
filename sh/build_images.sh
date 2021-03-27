#!/bin/bash -Eeu

source ${SH_DIR}/augmented_docker_compose.sh

# - - - - - - - - - - - - - - - - - - - - - -
build_images()
{
    local -r dil=$(docker image ls --format "{{.Repository}}:{{.Tag}}" --filter=reference="${CYBER_DOJO_DASHBOARD_IMAGE}*:*")
    local -r server_image="${CYBER_DOJO_DASHBOARD_IMAGE}:${CYBER_DOJO_DASHBOARD_TAG}"	
    local -r client_image="${CYBER_DOJO_DASHBOARD_CLIENT_IMAGE}:${CYBER_DOJO_DASHBOARD_TAG}"	

    remove_old_images "${dil}"
	
	# Avoid building (even with caches) for big win on Mac M1
    if [ $(echo "${dil}" | grep "${server_image}") ]; then
  	  if [ $(echo "${dil}" | grep "${client_image}") ]; then
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
    --build-arg COMMIT_SHA=$(git_commit_sha)

  docker tag ${CYBER_DOJO_DASHBOARD_IMAGE}:$(image_tag) ${CYBER_DOJO_DASHBOARD_IMAGE}:latest
  docker tag ${CYBER_DOJO_DASHBOARD_CLIENT_IMAGE}:$(image_tag) ${CYBER_DOJO_DASHBOARD_CLIENT_IMAGE}:latest

  check_embedded_env_var
  echo
  echo "echo CYBER_DOJO_DASHBOARD_SHA=${CYBER_DOJO_DASHBOARD_SHA}"
  echo "echo CYBER_DOJO_DASHBOARD_TAG=${CYBER_DOJO_DASHBOARD_TAG}"
  echo
}

# - - - - - - - - - - - - - - - - - - - - - -
check_embedded_env_var()
{
  if [ "$(git_commit_sha)" != "$(sha_in_image)" ]; then
    echo "ERROR: unexpected env-var inside image $(image_name):$(image_tag)"
    echo "expected: 'SHA=$(git_commit_sha)'"
    echo "  actual: 'SHA=$(sha_in_image)'"
    exit 42
  fi
}

# - - - - - - - - - - - - - - - - - - - - - -
remove_old_images()
{
  echo Removing old images
  local -r dil="${1}"
  remove_all_but_latest "${dil}" "${CYBER_DOJO_DASHBOARD_IMAGE}"
  remove_all_but_latest "${dil}" "${CYBER_DOJO_DASHBOARD_CLIENT_IMAGE}"
}

# - - - - - - - - - - - - - - - - - - - - - -
remove_all_but_latest()
{
  local -r docker_image_ls="${1}"
  local -r name="${2}"
  local -r tag="${CYBER_DOJO_DASHBOARD_TAG}"
  for image_name in `echo "${docker_image_ls}" | grep "${name}:"`
  do
    if [ "${image_name}" != "${name}:latest" ]; then
      if [ "${image_name}" != "${name}:<none>" ]; then
        if [ "${image_name}" != "${name}:${tag}" ]; then
          docker image rm "${image_name}"
        fi
      fi
    fi
  done
  docker system prune --force
}

