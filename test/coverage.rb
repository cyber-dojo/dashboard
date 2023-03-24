require 'simplecov'
require_relative 'simplecov_json'

SimpleCov.start do
  enable_coverage :branch
  filters.clear

  add_filter("/usr/")

  coverage_dir(ENV['COVERAGE_ROOT'])
  #add_group('debug') { |source| puts source.filename; false }
  code_tab = ENV['COVERAGE_CODE_TAB_NAME']
  test_tab = ENV['COVERAGE_TEST_TAB_NAME']
  add_group(code_tab) { |source| source.filename =~ %r"^/app/" }
  add_group(test_tab) { |source| source.filename =~ %r"^/test/.*_test\.rb$" }
end

SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
                                                                  SimpleCov::Formatter::HTMLFormatter,
                                                                  SimpleCov::Formatter::JSONFormatter
                                                                ])
