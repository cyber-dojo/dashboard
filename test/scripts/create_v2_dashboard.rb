#!/usr/bin/env ruby
# This has to run inside a docker-container so it can call the saver-service

require_relative 'extended_saver'

def create_v2_dashboard()
  p('Creating v2 dashboard')
  saver = ExtendedSaver.new
  p(saver.alive?)
end

create_v2_dashboard

# Need a externals-languages-start-points 

# all=$(kosli_get languages-start-points/manifests)
# manifests=$(echo "${all}" | jq '.manifests')
# names=$(echo "${manifests}" | jq 'keys')
# name=$(echo "${names}" | jq '.[2]') # eg "Bash 5.2.37, bats 1.12.0"
