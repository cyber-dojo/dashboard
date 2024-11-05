#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

docker run --rm --volume "${ROOT_DIR}:/app" cyberdojo/rubocop --raise-cop-error
