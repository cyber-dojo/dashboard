# frozen_string_literal: true

require 'simplecov'
require_relative 'simplecov_formatter_json'

SimpleCov.start do
  enable_coverage :branch
  filters.clear
  add_filter('test/id58_test_base.rb')
  coverage_dir(ENV.fetch('COVERAGE_ROOT'))
  # add_group('debug') { |source| puts source.filename; false }
  code_tab = ENV.fetch('COVERAGE_CODE_TAB_NAME')
  test_tab = ENV.fetch('COVERAGE_TEST_TAB_NAME')
  add_group(code_tab) { |source| source.filename =~ %r{^/dashboard/app/} }
  add_group(test_tab) { |source| source.filename =~ %r{^/dashboard/test/} }
end

formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter
]
SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(formatters)
