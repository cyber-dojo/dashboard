#!/usr/bin/env bash
set -Eeu

readonly my_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly assets_dir="${my_dir}/../source/server/app/assets"
source "${my_dir}/lib.sh"
export $(echo_env_vars)

exit_non_zero_unless_installed docker curl
docker compose --progress=plain up --detach --no-build --wait --wait-timeout=10 asset_builder
curl http://localhost:${CYBER_DOJO_ASSET_BUILDER_PORT}/assets/app.css > "${assets_dir}/stylesheets/pre-built-app.css"
curl http://localhost:${CYBER_DOJO_ASSET_BUILDER_PORT}/assets/app.js  > "${assets_dir}/javascripts/pre-built-app.js"
