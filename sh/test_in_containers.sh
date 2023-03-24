#!/usr/bin/env bash
set -Eeu

# - - - - - - - - - - - - - - - - - - - - - - - - - -
test_in_containers()
{
  if [ "${1}" == "$(server_name)" ]; then
    shift
    run_tests "$(server_user)" "$(server_container)" "$(server_name)" "${@:-}"
  elif [ "${1}" == "$(client_name)" ]; then
    shift
    run_tests "$(client_user)" "$(client_container)" "$(client_name)" "${@:-}"
  fi
  echo All passed
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -
run_tests()
{
  local -r USER="${1}"           # eg nobody
  local -r CONTAINER_NAME="${2}" # eg test_X_server
  local -r TYPE="${3}"           # eg client|server

  echo '=================================='
  echo "Running ${TYPE} tests"
  echo '=================================='

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Run tests (with branch coverage) inside the container.

  local -r COVERAGE_CODE_TAB_NAME=code
  local -r COVERAGE_TEST_TAB_NAME=test
  #local -r reports_dir_name=reports

  #local -r tmp_dir=/tmp
  local -r CONTAINER_TMP_DIR=/tmp

  #local -r coverage_root=/${CONTAINER_TMP_DIR}/${reports_dir_name}
  local -r CONTAINER_COVERAGE_DIR="${CONTAINER_TMP_DIR}/reports"

  #local -r test_log=test.log
  local -r TEST_LOG=test.log

  set +e
  docker exec \
    --env COVERAGE_CODE_TAB_NAME=${COVERAGE_CODE_TAB_NAME} \
    --env COVERAGE_TEST_TAB_NAME=${COVERAGE_TEST_TAB_NAME} \
    --user "${USER}" \
    "${CONTAINER_NAME}" \
      sh -c "/test/run.sh ${CONTAINER_COVERAGE_DIR} ${TEST_LOG} ${TYPE} ${*:4}"
  set -e


  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Extract test-run results and coverage data from the container.
  # You can't [docker cp] from a tmpfs, so tar-piping coverage out

  #local -r tests_type_dir="${ROOT_DIR}/$(tests_dir)/${TYPE}"
  local -r TESTS_TYPE_DIR="${ROOT_DIR}/$(tests_dir)/${TYPE}"

  docker exec \
    "${CONTAINER_NAME}" \
    tar Ccf \
      "$(dirname "${CONTAINER_COVERAGE_DIR}")" \
      - "$(basename "${CONTAINER_COVERAGE_DIR}")" \
        | tar Cxf "${TESTS_TYPE_DIR}/" -


  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Process test-run results and coverage data.

  #local -r reports_dir=${tests_type_dir}/${reports_dir_name}
  local -r HOST_REPORTS_DIR=${TESTS_TYPE_DIR}/reports
  mkdir -p "${HOST_REPORTS_DIR}"

  set +e

  docker run \
    --env COVERAGE_CODE_TAB_NAME=${COVERAGE_CODE_TAB_NAME} \
    --env COVERAGE_TEST_TAB_NAME=${COVERAGE_TEST_TAB_NAME} \
    --rm \
    --volume ${HOST_REPORTS_DIR}/${TEST_LOG}:${CONTAINER_TMP_DIR}/${TEST_LOG}:ro \
    --volume ${HOST_REPORTS_DIR}/index.html:${CONTAINER_TMP_DIR}/index.html:ro \
    --volume ${HOST_REPORTS_DIR}/coverage.json:${CONTAINER_TMP_DIR}/coverage.json:ro \
    --volume ${TESTS_TYPE_DIR}/metrics.rb:/app/metrics.rb:ro \
    cyberdojo/check-test-results:latest \
    sh -c "ruby /app/check_test_results.rb \
      ${CONTAINER_TMP_DIR}/${TEST_LOG} \
      ${CONTAINER_TMP_DIR}/index.html \
      ${CONTAINER_TMP_DIR}/coverage.json" \
      | tee -a ${HOST_REPORTS_DIR}/${TEST_LOG}

  local -r status=${PIPESTATUS[0]}
  set -e

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Tell caller where the results are...

  echo "${TYPE} test coverage at"
  echo "${HOST_REPORTS_DIR}/index.html"
  echo "${TYPE} test status == ${status}"
  if [ "${status}" != '0' ]; then
    echo Docker logs "${CONTAINER_NAME}"
    echo
    docker logs "${CONTAINER_NAME}"
  fi
  return ${status}
}
