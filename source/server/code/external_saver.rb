# frozen_string_literal: true
require_relative 'http_json_hash/service'

class ExternalSaver

  def initialize(http)
    @http = HttpJsonHash::service(self.class.name, http, 'saver', 4537)
  end

  def ready?
    @http.get(__method__, {})
  end

  # - - - - - - - - - - - - - - - - - - -

  def dir_make_command(dirname)
    ['dir_make',dirname]
  end

  def dir_exists_command(dirname)
    ['dir_exists?',dirname]
  end

  def file_create_command(filename, content)
    ['file_create',filename,content]
  end

  def file_read_command(filename)
    ['file_read',filename]
  end

  # - - - - - - - - - - - - - - - - - - -
  # primitives

  def run(command)
    @http.post(__method__, { command:command })
  end

  # - - - - - - - - - - - - - - - - - - -
  # batches

  def assert_all(commands)
    @http.post(__method__, { commands:commands })
  end

end
