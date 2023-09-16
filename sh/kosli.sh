#!/usr/bin/env bash
set -Eeu

export KOSLI_FLOW=dashboard
# KOSLI_ORG is set in CI
# KOSLI_API_TOKEN is set in CI
# KOSLI_HOST_STAGING is set in CI
# KOSLI_HOST_PRODUCTION is set in CI
# SNYK_TOKEN is set in CI

# - - - - - - - - - - - - - - - - - - -
kosli_create_flow()
{
  local -r hostname="${1}"

  kosli create flow "${KOSLI_FLOW}" \
    --description="UX for a group practice dashboard" \
    --host="${hostname}" \
    --template=artifact,snyk-scan \
    --visibility=public
}

# - - - - - - - - - - - - - - - - - - -
kosli_report_artifact_creation()
{
  local -r hostname="${1}"

  cd "$(root_dir)"  # So we don't need --repo-root flag

  kosli report artifact "$(artifact_name)" \
      --artifact-type=docker \
      --host="${hostname}"
}

# - - - - - - - - - - - - - - - - - - -
kosli_report_snyk_evidence()
{
  local -r hostname="${1}"

  kosli report evidence artifact snyk "$(artifact_name)" \
      --artifact-type=docker \
      --host="${hostname}" \
      --name=snyk-scan \
      --scan-results=snyk.json
}

# - - - - - - - - - - - - - - - - - - -
kosli_assert_artifact()
{
  local -r hostname="${1}"

  kosli assert artifact "$(artifact_name)" \
      --artifact-type=docker \
      --host="${hostname}"
}

# - - - - - - - - - - - - - - - - - - -
kosli_expect_deployment()
{
  local -r environment="${1}"
  local -r hostname="${2}"

  # In .github/workflows/main.yml deployment is its own job
  # and the image must be present to get its sha256 fingerprint.
  docker pull "$(artifact_name)"

  kosli expect deployment "$(artifact_name)" \
    --artifact-type=docker \
    --description="Deployed to ${environment} in Github Actions pipeline" \
    --environment="${environment}" \
    --host="${hostname}"
}

# - - - - - - - - - - - - - - - - - - -
on_ci_kosli_create_flow()
{
  if on_ci; then
    kosli_create_flow "${KOSLI_HOST_STAGING}"
    kosli_create_flow "${KOSLI_HOST_PRODUCTION}"
  fi
}

# - - - - - - - - - - - - - - - - - - -
on_ci_kosli_report_artifact_creation()
{
  if on_ci; then
    kosli_report_artifact_creation "${KOSLI_HOST_STAGING}"
    kosli_report_artifact_creation "${KOSLI_HOST_PRODUCTION}"
  fi
}

# - - - - - - - - - - - - - - - - - - -
on_ci_kosli_report_snyk_scan_evidence()
{
  if on_ci; then
    set +e
    snyk container test "$(artifact_name)" \
      --json-file-output=snyk.json \
      --policy-path="$(root_dir)/.snyk"
    set -e

    kosli_report_snyk_evidence "${KOSLI_HOST_STAGING}"
    kosli_report_snyk_evidence "${KOSLI_HOST_PRODUCTION}"
  fi
}

# - - - - - - - - - - - - - - - - - - -
on_ci_kosli_assert_artifact()
{
  if on_ci; then
    kosli_assert_artifact "${KOSLI_HOST_STAGING}"
    kosli_assert_artifact "${KOSLI_HOST_PRODUCTION}"
  fi
}

# - - - - - - - - - - - - - - - - - - -
artifact_name() {
  source "$(root_dir)/sh/echo_versioner_env_vars.sh"
  export $(echo_versioner_env_vars)
  echo "${CYBER_DOJO_DASHBOARD_IMAGE}:${CYBER_DOJO_DASHBOARD_TAG}"
}

# - - - - - - - - - - - - - - - - - - -
root_dir()
{
  # Functions in this file are called after sourcing (not including)
  # this file so root_dir() cannot use the path of this script.
  git rev-parse --show-toplevel
}

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci()
{
  [ -n "${CI:-}" ]
}
