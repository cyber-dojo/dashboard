require_relative 'http_json_hash/service'

class ExternalDiffer
  def initialize(http)
    hostname = ENV.fetch('CYBER_DOJO_DIFFER_HOSTNAME', 'differ')
    port = ENV.fetch('CYBER_DOJO_DIFFER_PORT', 4567)
    @http = HttpJsonHash.service(self.class.name, http, hostname, port)
  end

  def diff_summary(id, was_index, now_index)
    @http.get(__method__, { id: id, was_index: was_index, now_index: now_index })
  end
end
