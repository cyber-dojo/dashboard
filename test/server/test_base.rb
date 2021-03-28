# frozen_string_literal: true
require_relative '../id58_test_base'
require_source 'app'
require_source 'externals'

class TestBase < Id58TestBase

  include Rack::Test::Methods # [1]

  def app # [1]
    App.new(externals)
  end

  def externals
    @externals ||= Externals.new
  end

end
