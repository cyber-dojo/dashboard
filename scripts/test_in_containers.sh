#!/bin/bash -Eeu

# - - - - - - - - - - - - - - - - - - - - - - - - - -
test_in_containers()
{
  if [ "${1:-}" == "$(client_name)" ]; then
    shift
    run_client_tests "${@:-}"
  elif [ "${1:-}" == "$(server_name)" ]; then
    shift
    run_server_tests "${@:-}"
  else
    run_server_tests "${@:-}"
    run_client_tests "${@:-}"
  fi
  echo All passed
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -
run_client_tests()
{
  run_tests "$(client_user)" "$(client_container)" "$(client_name)" "${@:-}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -
run_server_tests()
{
  run_tests "$(server_user)" "$(server_container)" "$(server_name)" "${@:-}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -
run_tests()
{
  local -r USER="${1}"           # eg nobody
  local -r CONTAINER_NAME="${2}" # eg test_X_server
  local -r TYPE="${3}"           # eg client|server

  local -r reports_dir_name=reports
  local -r tmp_dir=/tmp
  local -r coverage_root=/${tmp_dir}/${reports_dir_name}
  local -r tests_type_dir="${ROOT_DIR}/$(tests_dir)/${TYPE}"
  local -r reports_dir=${tests_type_dir}/${reports_dir_name}
  local -r test_log=test.log
  local -r coverage_code_tab_name=code
  local -r coverage_test_tab_name=test

  echo '=================================='
  echo "Running ${TYPE} tests"
  echo '=================================='

  set +e
  docker exec \
    --env COVERAGE_CODE_TAB_NAME=${coverage_code_tab_name} \
    --env COVERAGE_TEST_TAB_NAME=${coverage_test_tab_name} \
    --user "${USER}" \
    "${CONTAINER_NAME}" \
      sh -c "/test/run.sh ${coverage_root} ${test_log} ${TYPE} ${*:4}"
  set -e

  # You can't [docker cp] from a tmpfs, so tar-piping coverage out
  docker exec \
    "${CONTAINER_NAME}" \
    tar Ccf \
      "$(dirname "${coverage_root}")" \
      - "$(basename "${coverage_root}")" \
        | tar Cxf "${tests_type_dir}/" -

  set +e
  docker run \
    --env COVERAGE_CODE_TAB_NAME=${coverage_code_tab_name} \
    --env COVERAGE_TEST_TAB_NAME=${coverage_test_tab_name} \
    --rm \
    --volume ${reports_dir}/${test_log}:${tmp_dir}/${test_log}:ro \
    --volume ${reports_dir}/index.html:${tmp_dir}/index.html:ro \
    --volume ${tests_type_dir}/metrics.rb:/app/metrics.rb:ro \
    cyberdojo/check-test-results:latest \
    sh -c "ruby /app/check_test_results.rb ${tmp_dir}/${test_log} ${tmp_dir}/index.html" \
      | tee -a ${reports_dir}/${test_log}
  local -r status=${PIPESTATUS[0]}
  set -e

  local -r coverage_path="${reports_dir}/index.html"
  echo "${TYPE} test coverage at ${coverage_path}"
  echo "${TYPE} test status == ${status}"
  if [ "${status}" != '0' ]; then
    echo
    docker logs "${CONTAINER_NAME}"
  fi
  return ${status}
}
