#!/bin/bash -Eeu

#- - - - - - - - - - - - - - - - - - - - - -
exit_zero_if_show_help()
{
  local -r MY_NAME=$(basename "${BASH_SOURCE[0]}")
  if [ "${1:-}" == '-h' ] || [ "${1:-}" == '--help' ]; then
    echo
    echo "Use: ${MY_NAME} [client|server] [ID...]"
    echo 'Options:'
    echo '   client  - only run the tests from inside the client'
    echo '   server  - only run the tests from inside the server'
    echo '   ID...   - only run the tests matching these identifiers'
    echo
    exit 0
  fi
}
