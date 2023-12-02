# frozen_string_literal: true

require_relative 'http_json_hash/service'

class ExternalSaver
  def initialize(http)
    hostname = ENV['CYBER_DOJO_SAVER_HOSTNAME']
    hostname = 'saver' if hostname.nil?
    port = ENV['CYBER_DOJO_SAVER_PORT']
    port = 4537 if port.nil?
    @http = HttpJsonHash.service(self.class.name, http, hostname, port)
  end

  def dir_exists_command(dirname)
    ['dir_exists?', dirname]
  end

  def file_read_command(filename)
    ['file_read', filename]
  end

  def run(command)
    @http.post(__method__, { command: command })
  end
end
