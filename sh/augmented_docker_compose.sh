#!/bin/bash -Eeu

# cyberdojo/service-yaml image lives at
# https://github.com/cyber-dojo-tools/service-yaml

# - - - - - - - - - - - - - - - - - - - - - -
augmented_docker_compose()
{
  cd "${ROOT_DIR}" && cat "./docker-compose.yml" \
    | docker run --rm --interactive cyberdojo/service-yaml \
                         differ \
                         model  \
                         saver  \
    | tee "/tmp/augmented-docker-compose.${SERVICE_NAME_LOWER}.peek.yml" \
    | docker-compose \
      --file -       \
      "$@"
}
