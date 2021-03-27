# frozen_string_literal: true
require_relative 'http_json_hash/service'

class ExternalSaver

  def initialize(http)
    @http = HttpJsonHash::service(self.class.name, http, 'saver', 4537)
  end

  def dir_exists_command(dirname)
    ['dir_exists?',dirname]
  end

  def file_read_command(filename)
    ['file_read',filename]
  end

  def run(command)
    @http.post(__method__, { command:command })
  end

end
