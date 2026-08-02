require_relative 'test_base'
require 'json'
require 'rack/builder'

class ConfigRuMountsBothPrefixesTest < TestBase
  # The suite normally drives App directly. This test needs the rack app that
  # config.ru actually builds, since the two mount points live only there.
  def app
    @app ||= Rack::Builder.parse_file(
      File.expand_path('../../source/config/config.ru', __dir__)
    )
  end

  test 'cnfg21', %w(
  | config.ru serves /alive at both of its mount points: the bare path, which
  | is what nginx's rewrite produces today, and the /dashboard path, which
  | arrives intact once that rewrite is deleted.
  ) do
    get '/alive'
    assert_equal 200, last_response.status, last_response.body
    assert_equal({ 'alive?' => true }, JSON.parse(last_response.body))

    get '/dashboard/alive'
    assert_equal 200, last_response.status, last_response.body
    assert_equal({ 'alive?' => true }, JSON.parse(last_response.body))
  end
end
