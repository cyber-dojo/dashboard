#!/usr/bin/env bash
set -Eeu

readonly my_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly tmp_dir=$(mktemp -d "/tmp/asset_builder.XXX")
remove_tmp_dir() { rm -rf "${tmp_dir}" > /dev/null; }
trap remove_tmp_dir INT EXIT

source "${my_dir}/lib.sh"
exit_non_zero_unless_installed docker curl
export $(echo_env_vars)

docker compose build --build-arg COMMIT_SHA="${COMMIT_SHA}" asset_builder
docker compose --progress=plain up --detach --no-build --wait --wait-timeout=10 asset_builder

readonly assets_dir="${my_dir}/../source/server/app/assets"

curl http://localhost:${CYBER_DOJO_ASSET_BUILDER_PORT}/assets/app.css > "${assets_dir}/stylesheets/pre-built-app.css"
curl http://localhost:${CYBER_DOJO_ASSET_BUILDER_PORT}/assets/app.js  > "${assets_dir}/javascripts/pre-built-app.js"
