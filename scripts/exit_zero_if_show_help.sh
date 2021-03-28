#!/bin/bash -Eeu

#- - - - - - - - - - - - - - - - - - - - - -
exit_zero_if_show_help()
{
  local -r MY_NAME=$(basename "${BASH_SOURCE[0]}")
  if [ "${1:-}" == '-h' ] || [ "${1:-}" == '--help' ]; then
    echo
    echo "Use: ${MY_NAME} [$(client_name)|$(server_name)] [ID...]"
    echo 'Options:'
    echo "   $(client_name)  - only run the tests from inside the $(client_name)"
    echo "   $(server_name)  - only run the tests from inside the $(server_name)"
    echo '   ID...   - only run the tests matching these identifiers'
    echo
    exit 0
  fi
}
