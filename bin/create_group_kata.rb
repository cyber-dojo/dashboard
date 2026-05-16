# frozen_string_literal: true

# Connects to the saver (its port is exposed to the host) and creates a v2
# group kata: Bash, bats / Fizz Buzz, with 16 avatars joined.
# Each avatar gets N red/amber/green traffic-light cycles (N = first arg, default 3).
# Prints the group ID on completion.

require 'json'
require 'net/http'

COUNT        = ARGV.fetch(0, '3').to_i
AVATAR_COUNT = ARGV.fetch(1, '16').to_i
SAVER_HOST   = 'localhost'
SAVER_PORT   = ENV.fetch('CYBER_DOJO_SAVER_PORT', '4537').to_i

# The substitution chain that produces red -> amber -> green per cycle:
#   red:   echo "${n}"  ->  echo "WIBBLE"   (wrong output for non-FizzBuzz numbers)
#   amber: echo "WIBBLE" -> echo "${n       (bash: bad substitution - syntax error)
#   green: echo "${n     -> echo "${n}"     (back to correct)
RED_LINE   = 'echo "WIBBLE"'
AMBER_LINE = 'echo "${n'
GREEN_LINE = 'echo "${n}"'

HIKER_SH = <<~BASH
  #!/bin/bash

  fizz_buzz()
  {
    local -r n=${1}
    if   [ $((n % 15)) -eq 0 ]; then echo 'FizzBuzz'
    elif [ $((n % 3))  -eq 0 ]; then echo 'Fizz'
    elif [ $((n % 5))  -eq 0 ]; then echo 'Buzz'
    else                              echo "${n}"
    fi
  }
BASH

TEST_HIKER_SH = <<~BASH
  #!/usr/bin/env bats

  source ./hiker.sh

  @test "1 gives 1" {
    [ "$(fizz_buzz 1)" = "1" ]
  }

  @test "3 gives Fizz" {
    [ "$(fizz_buzz 3)" = "Fizz" ]
  }

  @test "5 gives Buzz" {
    [ "$(fizz_buzz 5)" = "Buzz" ]
  }

  @test "15 gives FizzBuzz" {
    [ "$(fizz_buzz 15)" = "FizzBuzz" ]
  }
BASH

CYBER_DOJO_SH = "chmod 700 *.sh\n./test_hiker.sh\n"

BATS_HELP = "\nbats help is online at\nhttps://github.com/bats-core/bats-core#usage\n"

README = <<~TEXT
  Write a program that prints the numbers from 1 to 100.
  But for multiples of three print "Fizz" instead of the number,
  for multiples of five print "Buzz", and for numbers which are
  multiples of both three and five print "FizzBuzz".

  Sample output:
  1
  2
  Fizz
  4
  Buzz
  Fizz
  7
  8
  Fizz
  Buzz
  11
  Fizz
  13
  14
  FizzBuzz
  16
  17
  Fizz
  19
  Buzz
  ... etc up to 100
TEXT

RED_STDOUT = "1..4\nnot ok 1 1 gives 1\n" \
             "# (in test file ./test_hiker.sh, line 6)\n" \
             "#   `[ \"$(fizz_buzz 1)\" = \"1\" ]' failed\n" \
             "ok 2 3 gives Fizz\nok 3 5 gives Buzz\nok 4 15 gives FizzBuzz\n\n4 tests, 1 failure"

GREEN_STDOUT = "1..4\nok 1 1 gives 1\nok 2 3 gives Fizz\nok 3 5 gives Buzz\n" \
               "ok 4 15 gives FizzBuzz\n\n4 tests, 0 failures"

MANIFEST = {
  'display_name' => 'Bash, bats',
  'image_name' => 'cyberdojofoundation/bash_bats:53d0c9c',
  'filename_extension' => ['.sh'],
  'tab_size' => 4,
  'visible_files' => {
    'hiker.sh' => { 'content' => HIKER_SH, 'truncated' => false },
    'test_hiker.sh' => { 'content' => TEST_HIKER_SH, 'truncated' => false },
    'cyber-dojo.sh' => { 'content' => CYBER_DOJO_SH, 'truncated' => false },
    'bats_help.txt' => { 'content' => BATS_HELP, 'truncated' => false },
    'readme.txt' => { 'content' => README, 'truncated' => false }
  },
  'exercise' => 'Fizz Buzz',
  'version' => 2,
  'highlight_filenames' => [],
  'max_seconds' => 10,
  'progress_regexs' => [
    '\\d+ tests, [1-9]\\d* failure',
    '\\d+ tests, 0 failures'
  ]
}.freeze

def saver_get(path, args)
  saver_request(Net::HTTP::Get, path, args)
end

def saver_post(path, args)
  saver_request(Net::HTTP::Post, path, args)
end

def saver_request(method_class, path, args)
  uri = URI("http://#{SAVER_HOST}:#{SAVER_PORT}/#{path}")
  req = method_class.new(uri)
  req.content_type = 'application/json'
  req.body = JSON.generate(args)
  response = Net::HTTP.start(SAVER_HOST, SAVER_PORT) { |h| h.request(req) }
  JSON.parse(response.body)[path.to_s]
end

def file(content)
  { 'content' => content, 'truncated' => false }
end

def colour(hue)
  { 'colour' => hue, 'predicted' => 'none' }
end

def red_traffic_light(id, index, files)
  files['hiker.sh']['content'] = files['hiker.sh']['content'].sub(GREEN_LINE, RED_LINE)
  args = {
    id: id, index: index, files: files,
    stdout: file(RED_STDOUT), stderr: file(''),
    status: 1, summary: colour('red')
  }
  saver_post('kata_ran_tests', args)['next_index']
end

def amber_traffic_light(id, index, files)
  files['hiker.sh']['content'] = files['hiker.sh']['content'].sub(RED_LINE, AMBER_LINE)
  args = {
    id: id, index: index, files: files,
    stdout: file(''),
    stderr: file("./hiker.sh: line 10: `${n': bad substitution"),
    status: 1, summary: colour('amber')
  }
  saver_post('kata_ran_tests', args)['next_index']
end

def green_traffic_light(id, index, files)
  files['hiker.sh']['content'] = files['hiker.sh']['content'].sub(AMBER_LINE, GREEN_LINE)
  args = {
    id: id, index: index, files: files,
    stdout: file(GREEN_STDOUT), stderr: file(''),
    status: 0, summary: colour('green')
  }
  saver_post('kata_ran_tests', args)['next_index']
end

def rag_cycle(id, index, files, original_hiker)
  files['hiker.sh']['content'] = original_hiker
  index = red_traffic_light(id, index, files)
  index = amber_traffic_light(id, index, files)
  green_traffic_light(id, index, files)
end

def create_avatar(gid, count)
  id = saver_post('group_join', { id: gid })
  files = saver_get('kata_event', { id: id, index: 0 })['files']
  original_hiker = files['hiker.sh']['content']
  avatar_count = [1, (count / 2) + rand(count + 1)].max
  index = 1
  avatar_count.times { index = rag_cycle(id, index, files, original_hiker) }
end

gid = saver_post('group_create', { manifest: MANIFEST })
actual_avatar_count = [1, (AVATAR_COUNT / 2) + rand(AVATAR_COUNT + 1)].max
actual_avatar_count.times { create_avatar(gid, COUNT) }
puts gid
