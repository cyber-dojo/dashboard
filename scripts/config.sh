#!/bin/bash -Eeu

commit_sha() { echo $(cd "${ROOT_DIR}" && git rev-parse HEAD); }

image_sha() { commit_sha; }
image_tag() { image_sha | cut -c1-7; }

export COMMIT_TAG=$(image_tag)
export SERVICE_NAME=DASHBOARD
export SERVICE_NAME_LOWER=$(echo "${SERVICE_NAME}" | tr '[:upper:]' '[:lower:]')

SERVER_IMAGE="CYBER_DOJO_${SERVICE_NAME}_IMAGE" # from cyberdojo/versioner
SERVER_PORT="CYBER_DOJO_${SERVICE_NAME}_PORT"   # from cyberdojo/versioner

server_image()     { echo "${!SERVER_IMAGE}"; }
server_port()      { echo "${!SERVER_PORT}"; }
server_user()      { echo nobody; }
server_container() { echo test_${SERVICE_NAME_LOWER}_server; }

client_image()     { echo "cyberdojo/${SERVICE_NAME_LOWER}-client"; }
client_port()      { echo 9999; }
client_user()      { echo nobody; }
client_container() { echo test_${SERVICE_NAME_LOWER}_client; }

sources_dir() { echo sources; }
tests_dir()   { echo tests; }