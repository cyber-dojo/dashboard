# frozen_string_literal: true
require_relative 'http_json_hash/service'

class ExternalAvatars

  def initialize(http)
    @http = HttpJsonHash::service(self.class.name, http, 'avatars', 5027)
  end

  def ready?
    @http.get(__method__, {})
  end

  def names
    @http.get(__method__, {})
  end

end
