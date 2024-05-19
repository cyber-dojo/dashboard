#!/usr/bin/env bash
set -Eeu

create_docker_compose_yml()
{
  echo_docker_compose_yml > $(repo_root)/docker-compose.yml
}

echo_docker_compose_yml()
{
# Use un-expanded ${COMMIT_TAG} to avoid needless git diff churn.
# Note tests/ is volume-mapped to test/ because
# of an implementation dependency in cyberdojo/check-test-results
# See scripts/test_in_containers.sh
cat <<-EOF
# This file was auto-generated by ./scripts/create_docker_compose_yml.sh
# It is used by ./scripts/augmented_docker_compose.sh
# which saves a copy of the fully-augmented docker-compose.yml
# generated for each ./build_test_publish.sh command
# in /tmp/augmented-docker-compose.dashboard.peek.yml

services:

  nginx:
    build:
      context: test/nginx_stub
    container_name: test_dashboard_nginx
    depends_on:
      - $(client_name)
    image: cyberdojo/nginx_dashboard_stub
    ports: [ ${CYBER_DOJO_NGINX_PORT}:${CYBER_DOJO_NGINX_PORT} ]
    user: root

  $(client_name):
    image: $(client_image):\${COMMIT_TAG}
    user: $(client_user)
    build:
      args: [ COMMIT_SHA ]
      context: test/$(client_name)
    container_name: $(client_container)
    depends_on:
      - $(server_name)
    env_file: [ .env ]
    ports: [ $(client_port):$(client_port) ]
    read_only: true
    restart: "no"
    volumes:
      - ./test/$(client_name):/dashboard:ro
      - ./$(tests_dir):/test:ro
      - type: tmpfs
        target: /tmp
        tmpfs:
          mode: 01777
          size: 10485760  # 10MB

  $(server_name):
    image: $(server_image):\${COMMIT_TAG}
    user: $(server_user)
    build:
      context: .
      args: [ COMMIT_SHA ]
    container_name: $(server_container)
    depends_on:
      - differ
      - saver
    env_file: [ .env ]
    ports: [ $(server_port):$(server_port) ]
    read_only: true
    restart: "no"
    volumes:
      - ./app:/app:ro
      - ./$(tests_dir):/test:ro
      - type: tmpfs
        target: /tmp
        tmpfs:
          mode: 01777
          size: 10485760  # 10MB
EOF
}
