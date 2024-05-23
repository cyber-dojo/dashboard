#!/usr/bin/env bash
set -Eeu

# docker-compose.yml uses this:
#
# volumes:
#  - type: tmpfs
#    target: /tmp
#    tmpfs:
#      mode: 01777
#
# and the mode: option is not supported in the version of docker-compose
# currently installed in ubuntu-latest in the Github Action's main.yml
# https://stackoverflow.com/questions/49839028

sudo curl -L "https://github.com/docker/compose/releases/download/`curl -fsSLI -o /dev/null -w %{url_effective} https://github.com/docker/compose/releases/latest \
  | sed 's#.*tag/##g' && echo`/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
  && sudo chmod +x /usr/local/bin/docker-compose
