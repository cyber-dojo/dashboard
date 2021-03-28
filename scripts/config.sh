#!/bin/bash -Eeu

commit_sha() { echo -n $(cd "${ROOT_DIR}" && git rev-parse HEAD); }

image_sha() { commit_sha; }
image_tag() { image_sha | cut -c1-7; }

export COMMIT_TAG=$(image_tag)
export SERVICE_NAME=DASHBOARD
export SERVICE_NAME_LOWER=$(echo "${SERVICE_NAME}" | tr '[:upper:]' '[:lower:]')

SERVER_IMAGE="CYBER_DOJO_${SERVICE_NAME}_IMAGE" # from cyberdojo/versioner
SERVER_PORT="CYBER_DOJO_${SERVICE_NAME}_PORT"   # from cyberdojo/versioner

server_name()      { echo -n server; }
server_image()     { echo -n "${!SERVER_IMAGE}"; }
server_port()      { echo -n "${!SERVER_PORT}"; }
server_user()      { echo -n nobody; }
server_container() { echo -n test_${SERVICE_NAME_LOWER}_server; }

client_name()      { echo -n client; }
client_image()     { echo -n "cyberdojo/${SERVICE_NAME_LOWER}-client"; }
client_port()      { echo -n 9999; }
client_user()      { echo -n nobody; }
client_container() { echo -n test_${SERVICE_NAME_LOWER}_client; }

sources_dir() { echo -n sources; }
tests_dir()   { echo -n test; }