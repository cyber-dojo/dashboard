#!/usr/bin/env ruby
# frozen_string_literal: true

# -h  Show this help

if ARGV.include?('-h')
  puts <<~HELP
    Usage: ruby bin/rewrite_demo_timestamps.rb [-h]

    Reads saver_data.v2.tgz from stdin, rewrites all events.json timestamps
    to simulate a ~1-hour kata session starting at the current time, then
    writes the modified tgz to stdout.

    Each avatar starts within 0-60 seconds of the session start. Events
    are spread with randomised gaps: ~20% of gaps are under 60 seconds so
    two events sometimes fall in the same minute. About 35% of avatars are
    truncated to end on their last red (20%) or amber (15%) traffic light.
    manifest.json 'created' fields are set to the session start time.

    Example:
      ruby bin/rewrite_demo_timestamps.rb \\
        < test/data/saver_data.v2.tgz \\
        | docker exec -i saver tar --no-xattrs -zxf - -C /
  HELP
  exit 0
end

require 'json'
require 'zlib'

BLOCK         = 512
SESSION_START = Time.now

def random_ending(events)
  r = rand
  return events if r >= 0.35

  target = r < 0.20 ? 'red' : 'amber'
  last_pos = events.rindex { |e| e['colour'] == target }
  return events if last_pos.nil? || last_pos == events.size - 1

  events[0..last_pos]
end

def rewrite_events(raw, avatar_start)
  events = JSON.parse(raw)
  events = random_ending(events)
  elapsed = 0
  events.each_with_index do |event, i|
    elapsed += (rand < 0.20 ? rand(10..59) : rand(60..300)) if i > 0
    t = avatar_start + elapsed
    event['time'] = [t.year, t.month, t.day, t.hour, t.min, t.sec, rand(1_000_000)]
  end
  JSON.generate(events)
end

def rewrite_manifest_created(raw)
  manifest = JSON.parse(raw)
  return raw unless manifest.key?('created')
  t = SESSION_START
  manifest['created'] = [t.year, t.month, t.day, t.hour, t.min, t.sec, 0]
  JSON.generate(manifest)
end

def updated_header(block, new_size)
  b = block.dup
  b[124, 12] = format('%011o', new_size) + "\0"
  b[148, 8]  = ' ' * 8
  b[148, 8]  = format('%06o', b.bytes.sum) + "\0 "
  b
end

def pad_to_block(data)
  rem = data.bytesize % BLOCK
  rem.zero? ? data : data + "\0" * (BLOCK - rem)
end

def regular_file?(typeflag)
  typeflag == '0' || typeflag == "\0"
end

$stdin.binmode
$stdout.binmode

gz_in  = Zlib::GzipReader.new($stdin)
gz_out = Zlib::GzipWriter.new($stdout)

loop do
  header = gz_in.read(BLOCK)
  break if header.nil?

  if header == "\0" * BLOCK
    gz_out.write(header)
    extra = gz_in.read(BLOCK)
    gz_out.write(extra) if extra
    break
  end

  size     = header[124, 12].strip.to_i(8)
  typeflag = header[156, 1]
  name     = header[0, 100].delete("\0")
  magic    = header[257, 6]
  prefix   = magic&.start_with?('ustar') ? header[345, 155].delete("\0") : ''
  full     = prefix.empty? ? name : "#{prefix}/#{name}"

  padded_size = size > 0 ? ((size + BLOCK - 1) / BLOCK) * BLOCK : 0
  raw = padded_size > 0 ? gz_in.read(padded_size) : ''

  if regular_file?(typeflag)
    content = raw[0, size] || ''

    new_content =
      if full.end_with?('/events.json')
        avatar_start = SESSION_START + rand(60)
        rewrite_events(content, avatar_start) rescue content
      elsif full.end_with?('/manifest.json')
        rewrite_manifest_created(content) rescue content
      else
        content
      end

    gz_out.write(updated_header(header, new_content.bytesize))
    gz_out.write(pad_to_block(new_content))
  else
    gz_out.write(header)
    gz_out.write(raw) unless raw.empty?
  end
end

gz_out.close
