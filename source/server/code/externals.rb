# frozen_string_literal: true
require_relative 'external_avatars'
require_relative 'external_http'
require_relative 'external_saver'
require_relative 'external_time'

class Externals

  def avatars
    @avatars ||= ExternalAvatars.new(avatars_http)
  end
  def avatars_http
    @avatars_http ||= ExternalHttp.new
  end

  def saver
    @saver ||= ExternalSaver.new(saver_http)
  end
  def saver_http
    @saver_http ||= ExternalHttp.new
  end

  def time
    @time ||= ExternalTime.new
  end

end
