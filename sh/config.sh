#!/bin/bash -Eeu

export SERVICE_NAME=DASHBOARD
export SERVICE_NAME_LOWER=$(echo "${SERVICE_NAME}" | tr '[:upper:]' '[:lower:]')

# - - - - - - - - - - - - - - - - - - - - - - - -

commit_sha() { echo $(cd "${ROOT_DIR}" && git rev-parse HEAD); }

image_sha() { commit_sha; }

image_tag() { image_sha | cut -c1-7; }

# - - - - - - - - - - - - - - - - - - - - - -

# from versioner's output
SERVER_IMAGE="CYBER_DOJO_${SERVICE_NAME}_IMAGE"
SERVER_PORT="CYBER_DOJO_${SERVICE_NAME}_PORT"

server_image()     { echo "${!SERVER_IMAGE}"; }
server_port()      { echo "${!SERVER_PORT}"; }
server_user()      { echo nobody; }
server_container() { echo test_${SERVICE_NAME_LOWER}_server; }

client_image()     { echo "cyberdojo/${SERVICE_NAME_LOWER}-client"; }
client_port()      { echo 9999; }
client_user()      { echo nobody; }
client_container() { echo test_${SERVICE_NAME_LOWER}_client; }
