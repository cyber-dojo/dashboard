# frozen_string_literal: true

require 'simplecov'
require_relative 'simplecov_json'

SimpleCov.start do
  enable_coverage :branch
  filters.clear
  # add_filter("test/id58_test_base.rb")
  coverage_dir(ENV.fetch('COVERAGE_ROOT', nil))
  # add_group('debug') { |source| puts source.filename; false }
  code_tab = ENV.fetch('COVERAGE_CODE_TAB_NAME', nil)
  test_tab = ENV.fetch('COVERAGE_TEST_TAB_NAME', nil)
  add_group(code_tab) { |source| source.filename =~ %r{^/app/} }
  add_group(test_tab) { |source| source.filename =~ %r{^/test/.*_test\.rb$} }
end

SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
                                                                  SimpleCov::Formatter::HTMLFormatter,
                                                                  SimpleCov::Formatter::JSONFormatter
                                                                ])
