# frozen_string_literal: true

# This has to run inside a docker-container so it can call the dependent services

require 'json'
require_relative 'external_differ'
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
  # { index:0, event:created }

  files = manifest['visible_files']
  new_filename = 'wibble.txt'
  files['cyber-dojo.sh']['content'] += '#comment'
  index = 1
  index = saver.kata_file_create(kid, index, files, filename=new_filename)
  # VIP that new_filename is added only now.
  files[new_filename] = { 'content' => '' }
  # { index:1, event:edit-file, filename:'cyber-dojo.sh'}
  # { index:2, event:create-file, filename:'wibble.txt'}

  files[new_filename]['content'] += 'Hello world'
  index = saver.kata_file_switch(kid, index, files)
  # { index:3, event:edit-file, filename:'wibble.txt'}

  stdout = { 'content' => '', 'truncated' => false }
  stderr = { 'content' => '', 'truncated' => false }
  status = '0'
  summary = {
    duration: 1.234,
    colour: 'red',
    predicted: 'none',
    revert_if_wrong: false
  }
  index = saver.kata_ran_tests(kid, index, files, stdout, stderr, status, summary)
  # { index:4, colour:red }

  # index = saver.kata_file_delete(kid, index, files, filename)
  # index = saver.kata_file_rename(kid, index, files, old_filename, new_filename)

  events = saver.kata_events(kid)
  puts(events)
  # { index:0, event:created }
  # { index:1, event:edit-file, filename:'cyber-dojo.sh'}
  # { index:2, event:create-file, filename:'wibble.txt'}
  # { index:3, event:edit-file, filename:'wibble.txt'}
  # { index:4, colour:red }

  puts("http://localhost:80/dashboard/show/#{gid}?auto_refresh=false&minute_columns=true")

  # The red traffic-light's tool-top gives plain red. Clicking it takes you to
  # http://localhost/review/show/L5Gw6Y?was_index=3&now_index=4
  # which is 3->4 which has no actual diff.
  # Changing the URL to 
  # http://localhost/review/show/L5Gw6Y?was_index=0&now_index=4
  # gives the same
  #
  # So initial impressions look like differ is not working *across* the new non-test events.
  # Next step could be to add external-differ and see what various diffs are.

  show_diff(kid, 0, 1)
  show_diff(kid, 1, 2)
  show_diff(kid, 2, 3)
  show_diff(kid, 3, 4)
  show_diff(kid, 0, 4)

  # I think there is an error in saver.kata_file_create()
  # It is showing
  # Diff 0 - 1
  # ----{"type"=>"changed", "new_filename"=>"cyber-dojo.sh", "old_filename"=>"cyber-dojo.sh", 
  #      "line_counts"=>{"added"=>1, "deleted"=>0, "same"=>23}}
  #
  # Diff 1 - 2
  # ----{"type"=>"created", "new_filename"=>"wibble.txt", "old_filename"=>nil, 
  #     "line_counts"=>{"added"=>0, "deleted"=>0, "same"=>0}}
  #
  # Diff 2 - 3
  # ----{"type"=>"changed", "new_filename"=>"wibble.txt", "old_filename"=>"wibble.txt", 
  #      "line_counts"=>{"added"=>1, "deleted"=>0, "same"=>0}}
  #
  # Diff 3 - 4
  #
  # Diff 0 - 4
  # ----{"type"=>"changed", "new_filename"=>"cyber-dojo.sh", "old_filename"=>"cyber-dojo.sh", "line_counts"=>{"added"=>1, "deleted"=>0, "same"=>23}}
  # ----{"type"=>"created", "new_filename"=>"wibble.txt", "old_filename"=>nil, "line_counts"=>{"added"=>1, "deleted"=>0, "same"=>0}}
  #
  # This looks right.
end

def show_diff(id, was_index, now_index)
  differ = ExternalDiffer.new
  diff = differ.diff_summary(id, was_index, now_index)
  puts()
  puts("Diff #{was_index} - #{now_index}")
  diff.each do |entry|
    if entry["type"] != "unchanged"
      puts("----#{entry}")
    end
  end
end

create_v2_dashboard
