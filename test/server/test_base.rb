require 'rack/test'
require_relative '../id58_test_base'
require_source 'app'
require_source 'externals'

class TestBase < Id58TestBase
  include Rack::Test::Methods

  def app
    App.new(externals)
  end

  def externals
    @externals ||= Externals.new
  end

  # True when the last response status matches expected.
  def status?(expected)
    status == expected
  end

  # The last response's HTTP status code.
  def status
    last_response.status
  end

  # True when the last response was served as CSS.
  def css_content?
    content_type == 'text/css;charset=utf-8'
  end

  # True when the last response was served as JavaScript.
  def js_content?
    content_type == 'text/javascript;charset=utf-8'
  end

  # The last response's Content-Type header.
  def content_type
    last_response.headers['Content-Type']
  end
end
