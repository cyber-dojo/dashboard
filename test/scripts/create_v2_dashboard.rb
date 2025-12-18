# frozen_string_literal: true

# This has to run inside a docker-container so it can call the dependent services

require 'json'
require_relative 'external_exercises_start_points'
require_relative 'external_languages_start_points'
require_relative 'external_saver'

def create_v2_dashboard
  p('Creating v2 dashboard')
  lsp = ExternalLanguagesStartPoints.new
  esp = ExternalExercisesStartPoints.new
  saver = ExternalSaver.new

  lsp_names = lsp.manifests.keys
  lsp_name = lsp_names[2] # eg "Bash 5.2.37, bats 1.12.0"
  esp_names = esp.manifests.keys # eg "Fizz Buzz"
  esp_name = esp_names[19]

  manifest = lsp.manifest(lsp_name)
  exercise = esp.manifest(esp_name)
  manifest['visible_files'].merge!(exercise['visible_files'])
  manifest['exercise'] = exercise['display_name']
  gid = saver.group_create(manifest)
  puts("Group ID=#{gid}")
  kid = saver.group_join(gid)
  puts("Kata ID=#{kid}")

  files = manifest['visible_files']
  new_filename = 'wibble.txt'
  files[new_filename] = { 'content' => '' }
  files['cyber-dojo.sh']['content'] += '#comment'
  index = 1
  index = saver.kata_file_create(kid, index, files, filename=new_filename)

  files[new_filename]['content'] += 'Hello world'
  index = saver.kata_file_switch(kid, index, files)

  # index = saver.kata_file_delete(kid, index, files, filename)
  # index = saver.kata_file_rename(kid, index, files, old_filename, new_filename)

  stdout = { 'content' => '', 'truncated' => false }
  stderr = { 'content' => '', 'truncated' => false }
  status = '0'
  summary = {
    duration: 1.234,
    colour: 'red',
    predicted: nil,
    revert_if_wrong: false
  }
  index = saver.kata_ran_tests(kid, index, files, stdout, stderr, status, summary)

  events = saver.kata_events(kid)

  puts(events)
  puts("http://localhost:80/dashboard/show/#{gid}?auto_refresh=false&minute_columns=true")
end

create_v2_dashboard
