
# - - - - - - - - - - - - - - - - - - - - - -
remove_old_images()
{
  echo Removing old images
  local -r dil=$(docker image ls --format "{{.Repository}}:{{.Tag}}")
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
