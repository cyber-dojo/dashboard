
# - - - - - - - - - - - - - - - - - - -
server_up_healthy_and_clean()
{
  if [ "${1}" == $(server_name) ]; then
    export CONTAINER_NAME="$(server_container)"
    export CONTAINER_PORT="$(server_port)"
    export CONTAINER_USER="$(server_user)"
    augmented_docker_compose up --detach $(server_name)
    exit_non_zero_unless_healthy
    exit_non_zero_unless_started_cleanly
  fi
}

# - - - - - - - - - - - - - - - - - - -
client_up_healthy_and_clean()
{
  if [ "${1}" == $(client_name) ]; then
    export CONTAINER_NAME="$(client_container)"
    export CONTAINER_PORT="$(client_port)"
    export CONTAINER_USER="$(client_user)"
    augmented_docker_compose up --detach $(client_name)
    exit_non_zero_unless_healthy
    exit_non_zero_unless_started_cleanly
  fi
}

# - - - - - - - - - - - - - - - - - - -
exit_non_zero_unless_healthy()
{
  echo
  local -r MAX_TRIES=50
  printf "Waiting until ${CONTAINER_NAME} is healthy"
  for _ in $(seq ${MAX_TRIES})
  do
    if healthy; then
      echo; echo "${CONTAINER_NAME} is healthy."
      return
    else
      printf .
      sleep 0.1
    fi
  done
  echo; echo "${CONTAINER_NAME} not healthy after ${MAX_TRIES} tries."
  echo_docker_log
  echo
  exit 42
}

# - - - - - - - - - - - - - - - - - - -
healthy()
{
  docker ps --filter health=healthy --format '{{.Names}}' | grep -q "${CONTAINER_NAME}"
}

# - - - - - - - - - - - - - - - - - - -
exit_non_zero_unless_started_cleanly()
{
  echo
  local DOCKER_LOG=$(echo_docker_log)

  # Handle known warnings (eg waiting on Gem upgrade)
  #local -r SHADOW_WARNING="server.rb:(.*): warning: shadowing outer local variable - filename"
  #DOCKER_LOG=$(strip_known_warning "${DOCKER_LOG}" "${SHADOW_WARNING}")

  echo "Checking if ${SERVICE_NAME} started cleanly."
  local -r top5=$(echo "${DOCKER_LOG}" | head -5)
  if [ "${top5}" == "$(clean_top_5)" ]; then
    echo "${SERVICE_NAME} started cleanly."
  else
    echo "${SERVICE_NAME} did not start cleanly."
    echo 'expected------------------'
    echo
    echo "${clean_top_5}"
    echo
    echo 'actual--------------------'
    echo
    echo "${top5}"
    echo
    echo 'diff--------------------'
    #echo "First 10 lines of: docker logs ${CONTAINER_NAME}"
    #echo
    #echo "${DOCKER_LOG}" | head -10
    #echo
    grep -Fxvf <(echo "${clean_top_5}") <(echo "${top_5}")
    echo
    exit 42
  fi
}

# - - - - - - - - - - - - - - - - - - -
clean_top_5()
{
  # 1st 6 lines on Puma
  local -r L1="Puma starting in single mode..."
  local -r L2='* Puma version: 6.1.1 (ruby 3.2.1-p31) ("The Way Up")'
  local -r L3="*  Min threads: 0"
  local -r L4="*  Max threads: 5"
  local -r L5="*  Environment: production"
  #
  local -r top5="$(printf "%s\n%s\n%s\n%s\n%s" "${L1}" "${L2}" "${L3}" "${L4}" "${L5}")"
  echo "${top5}"
}

# - - - - - - - - - - - - - - - - - - -
echo_docker_log()
{
  docker logs "${CONTAINER_NAME}" 2>&1
}

# - - - - - - - - - - - - - - - - - - -
strip_known_warning()
{
  local -r DOCKER_LOG="${1}"
  local -r KNOWN_WARNING="${2}"
  local STRIPPED=$(echo -n "${DOCKER_LOG}" | grep --invert-match -E "${KNOWN_WARNING}")
  if [ "${DOCKER_LOG}" != "${STRIPPED}" ]; then
    echo "Known service start-up warning found: ${KNOWN_WARNING}"
  else
    echo "Known service start-up warning NOT found: ${KNOWN_WARNING}"
    exit 42
  fi
  echo "${STRIPPED}"
}
