# frozen_string_literal: true

# This has to run inside a docker-container so it can call the dependent services

require_relative 'extended_saver'

def create_v2_dashboard
  p('Creating v2 dashboard')
  saver = ExtendedSaver.new
  p(saver.ready?)
end

create_v2_dashboard

# Need an externals-languages-start-points
# and exercises-start-points, which have to be combined in some way...
# Can steal from creator repo I think

# all=$(kosli_get languages-start-points/manifests)
# manifests=$(echo "${all}" | jq '.manifests')
# names=$(echo "${manifests}" | jq 'keys')
# name=$(echo "${names}" | jq '.[2]') # eg "Bash 5.2.37, bats 1.12.0"
