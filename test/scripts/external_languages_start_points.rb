# frozen_string_literal: true

require_relative 'require_source'
require_source 'external_http'
require_source 'http_json_hash/service'

# Languages-Start-Points microservice
class ExternalLanguagesStartPoints
  def initialize
    hostname = 'languages-start-points'
    port = ENV.fetch('CYBER_DOJO_LANGUAGES_START_POINTS_PORT')
    @http = HttpJsonHash.service(self.class.name, ExternalHttp.new, hostname, port)
  end

  def manifests
    @http.get(__method__, {})
  end 

  def manifest(name)
    @http.get(__method__, { name: name })
  end
end
