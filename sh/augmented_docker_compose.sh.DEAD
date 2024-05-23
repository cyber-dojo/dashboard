#!/usr/bin/env bash
set -Eeu

# cyberdojo/service-yaml image lives at
# https://github.com/cyber-dojo-tools/service-yaml

# - - - - - - - - - - - - - - - - - - - - - -
augmented_docker_compose()
{
  # When you run this you get a diagnostic message
  #   Docker Compose is now in the Docker CLI, try `docker compose up`
  # But that doesn't work. Currently, you still need docker-compose
  cd "$(repo_root)" && cat "./docker-compose.yml" \
    | docker run \
        --rm \
        --interactive \
          cyberdojo/service-yaml \
              differ \
              saver  \
    | tee "/tmp/augmented-docker-compose.${SERVICE_NAME_LOWER}.peek.yml" \
    | docker-compose \
      --file -       \
      "$@"
}
