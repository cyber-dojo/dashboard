#!/bin/bash -Eeu

#- - - - - - - - - - - - - - - - - - - - - -
exit_zero_if_show_help()
{
  local -r MY_NAME=$(basename "${BASH_SOURCE[0]}")
  if [ "${1:-}" == '-h' ] || [ "${1:-}" == '--help' ]; then
    echo
    echo "Use: ${MY_NAME} $(server_name) [ID...]"
    echo "Use: ${MY_NAME} $(client_name) [ID...]"
    echo "Use: ${MY_NAME} -h|--help"
    echo 'Options:'
    echo "   $(server_name)      run the tests from inside the $(server_name)"
    echo "   $(client_name)      run the tests from inside the $(client_name)"
    echo '   ID...       only run the tests matching these identifiers'
    echo '   -h|--help   show this help'
    echo
    exit 0
  fi
}
