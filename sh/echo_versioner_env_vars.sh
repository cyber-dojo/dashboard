#!/bin/bash -Eeu

export SERVICE_NAME=DASHBOARD
export SERVICE_NAME_LOWER=$(echo "${SERVICE_NAME}" | tr '[:upper:]' '[:lower:]')

# - - - - - - - - - - - - - - - - - - - - - - - -
echo_versioner_env_vars()
{
  # This functions' output must be exported. 
  # See the top of build_test_publish.sh   
  docker run --rm cyberdojo/versioner
  
  # Create env-vars needed in docker-compose.yml  
  echo CYBER_DOJO_${SERVICE_NAME}_SERVER_USER=nobody
  echo CYBER_DOJO_${SERVICE_NAME}_CLIENT_USER=nobody

  # CYBER_DOJO_${SERVICE_NAME}_IMAGE is in versioner
  echo CYBER_DOJO_${SERVICE_NAME}_CLIENT_IMAGE=cyberdojo/${SERVICE_NAME_LOWER}-client

  # CYBER_DOJO_${SERVICE_NAME}_PORT is in versioner 
  echo CYBER_DOJO_${SERVICE_NAME}_CLIENT_PORT=9999

  echo CYBER_DOJO_${SERVICE_NAME}_CLIENT_CONTAINER=test_${SERVICE_NAME_LOWER}_client
  echo CYBER_DOJO_${SERVICE_NAME}_SERVER_CONTAINER=test_${SERVICE_NAME_LOWER}_server

  echo CYBER_DOJO_${SERVICE_NAME}_SHA="$(image_sha)"
  echo CYBER_DOJO_${SERVICE_NAME}_TAG="$(image_tag)"
}

# - - - - - - - - - - - - - - - - - - - - - - - -

commit_sha() { echo $(cd "${ROOT_DIR}" && git rev-parse HEAD); }

sha_in_image() { docker run --rm $(server_image):$(image_tag) sh -c 'echo -n ${SHA}'; }

image_sha() { commit_sha; }

image_tag() { image_sha | cut -c1-7; }

# - - - - - - - - - - - - - - - - - - - - - -
server_image() 
{ 
  local -r name="CYBER_DOJO_${SERVICE_NAME}_IMAGE"
  echo "${!name}" 
}

client_image() 
{ 
  local -r name="CYBER_DOJO_${SERVICE_NAME}_CLIENT_IMAGE"
  echo "${!name}" 
}
