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
  saver.kata_file_create(kid, index=1, files, filename=new_filename)

  # saver.kata_file_delete(kid, index, files, filename)
  # saver.kata_file_rename(kid, index, files, old_filename, new_filename)
  # saver.kata_file_switch(kid, index, files)

  # saver.kata_ran_tests(kid)

  events = saver.kata_events(kid)
  puts(events)
end

create_v2_dashboard
