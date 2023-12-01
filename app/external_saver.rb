# frozen_string_literal: true
require_relative 'http_json_hash/service'

class ExternalSaver

  def initialize(http)
    hostname = ENV['CYBER_DOJO_SAVER_HOSTNAME']
    if hostname.nil?
      hostname = 'saver'
    end
    port = ENV['CYBER_DOJO_SAVER_PORT']
    if port.nil?
      port = 4537
    end
    @http = HttpJsonHash::service(self.class.name, http, hostname, port)
  end

  def ready?
    @http.get(__method__, {})
  end

  def group_manifest(id)
    @http.get(__method__, { id:id })
  end

  def group_joined(id)
    @http.get(__method__, { id:id })
  end

  def katas_events(ids, indexes)
    @http.get(__method__, { ids:ids, indexes:indexes })
  end

end
