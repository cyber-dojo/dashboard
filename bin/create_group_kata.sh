#!/usr/bin/env bash
set -Eeu

if [[ "${1:-}" == '-h' ]]; then
  cat << 'HELP'
Usage: bin/create_group_kata.sh [traffic_light_count] [avatar_count]

  traffic_light_count  Approx number of red/amber/green cycles per avatar (default: 3)
  avatar_count         Approx number of avatars to join the group (default: 16)

Creates a bash/bats FizzBuzz group kata in the running saver, prints the group ID (GID).

Step-by-step: create new demo kata and load it into demo
---------------------------------------------------------
1. Start the demo:
     make demo

2. Create a new group kata (tune counts as needed; start small):
     bash bin/create_group_kata.sh 5 20
   Note the GID printed on the last line.

3. Verify it looks right in the dashboard:
     open "http://localhost/dashboard/show/<GID>?auto_refresh=true&minute_columns=true"

4. Save the saver data to the tgz:
     bash bin/copy_out_saver_data.sh

5. Update bin/demo.sh, changing the GID line to:
     GID=<new_GID>

6. Run make demo again to verify the new tgz loads correctly:
     make demo

7. Commit the updated tgz and demo.sh.
HELP
  exit 0
fi

readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/bin/lib.sh"
source "${ROOT_DIR}/bin/echo_env_vars.sh"
export $(echo_env_vars)

exit_non_zero_unless_installed ruby

readonly traffic_light_count="${1:-3}"
readonly avatar_count="${2:-16}"
ruby "${ROOT_DIR}/bin/create_group_kata.rb" "${traffic_light_count}" "${avatar_count}"
