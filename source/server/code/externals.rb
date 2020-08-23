# frozen_string_literal: true
require_relative 'external_http'
require_relative 'external_saver'

class Externals

  def saver
    @saver ||= ExternalSaver.new(saver_http)
  end
  def saver_http
    @saver_http ||= ExternalHttp.new
  end

end
