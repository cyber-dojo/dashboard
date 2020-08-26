require 'simplecov'

SimpleCov.start do
  #enable_coverage :branch
  filters.clear
  coverage_dir(ENV['COVERAGE_ROOT'])
  #add_group('debug') { |source| puts source.filename; false }
  code_tab = ENV['COVERAGE_CODE_TAB_NAME']
  test_tab = ENV['COVERAGE_TEST_TAB_NAME']
  add_group(code_tab) { |source| source.filename =~ %r"^/app/" }
  add_group(test_tab) { |source| source.filename =~ %r"^/test/.*_test\.rb$" }
end
