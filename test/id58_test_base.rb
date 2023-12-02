# frozen_string_literal: true

require 'English'
require 'minitest/autorun'
require 'rack/test'

def require_source(required)
  require_relative "../dashboard/app/#{required}"
end

class Id58TestBase < Minitest::Test
  def initialize(arg)
    @id58 = nil
    @name58 = nil
    super
  end

  @@args = (ARGV.sort.uniq - ['--']) # eg 2m4
  @@seen_ids = []
  @@timings = {}

  # - - - - - - - - - - - - - - - - - - - - - -

  def self.test(id58_suffix, *lines, &test_block)
    source = test_block.source_location
    source_file = File.basename(source[0])
    source_line = source[1].to_s
    id58 = checked_id58(id58_suffix.to_s, lines)
    return unless @@args === [] || @@args.any? { |arg| id58.include?(arg) }

    name58 = lines.join(' ')
    execute_around = lambda {
      ENV['ID58'] = id58
      @id58 = id58
      @name58 = name58
      id58_setup
      begin
        t1 = Time.now
        instance_exec(&test_block)
        t2 = Time.now
        stripped = trimmed(name58.split("\n").join)
        @@timings["#{id58}:#{source_file}:#{source_line}:#{stripped}"] = (t2 - t1)
      ensure
        puts $ERROR_INFO.message unless $ERROR_INFO.nil?
        id58_teardown
      end
    }
    name = "#{id58_suffix}:#{name58}"
    define_method(:"test_

#{name}", &execute_around)
  end

  def trimmed(s)
    if s.length > 80
      "#{s[0..80]}..."
    else
      s
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  Minitest.after_run do
    slow = @@timings.select { |_name, secs| secs > 0.000 }
    sorted = slow.sort_by { |_name, secs| -secs }.to_h
    size = [sorted.size, 5].min
    puts
    puts "Slowest #{size} tests are..." if size != 0
    sorted.each_with_index do |(name, secs), index|
      puts format('%3.4f - %-72s', secs, name)
      break if index === size
    end
    puts
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  ID58_ALPHABET = %w[
    0 1 2 3 4 5 6 7 8 9
    A B C D E F G H J K L M N P Q R S T U V W X Y Z
    a b c d e f g h j k l m n p q r s t u v w x y z
  ].join.freeze

  def self.id58?(s)
    s.instance_of?(String) &&
      s.chars.all? { |ch| ID58_ALPHABET.include?(ch) }
  end

  def self.checked_id58(id58_suffix, lines)
    method = 'def self.id58_prefix'
    pointer = "#{' ' * method.index('.')}!"
    pointee = ['', pointer, method, '', ''].join("\n")
    pointer.prepend("\n\n")
    raise "#{pointer}missing#{pointee}" unless respond_to?(:id58_prefix)

    prefix = id58_prefix.to_s
    raise "#{pointer}empty#{pointee}" if prefix === ''
    raise "#{pointer}not id58#{pointee}" unless id58?(prefix)

    method = "test '#{id58_suffix}',"
    pointer = "#{' ' * method.index("'")}!"
    proposition = lines.join(' ')
    pointee = ['', pointer, method, "'#{proposition}'", '', ''].join("\n")
    id58 = prefix + id58_suffix
    pointer.prepend("\n\n")
    raise "#{pointer}empty#{pointee}" if id58_suffix === ''
    raise "#{pointer}not id58#{pointee}" unless id58?(id58_suffix)
    raise "#{pointer}duplicate#{pointee}" if @@seen_ids.include?(id58)
    raise "#{pointer}overlap#{pointee}" if prefix[-2..] === id58_suffix[0..1]

    @@seen_ids << id58
    id58
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def id58_setup; end

  def id58_teardown; end

  # - - - - - - - - - - - - - - - - - - - - - -

  attr_reader :id58, :name58
end
