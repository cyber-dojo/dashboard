require_relative 'require_source'
require_source 'external_http'
require_source 'http_json_hash/service'

# Saver microservice
class ExternalSaver
  def initialize
    hostname = 'saver'
    port = ENV.fetch('CYBER_DOJO_SAVER_PORT')
    @http = HttpJsonHash.service(self.class.name, ExternalHttp.new, hostname, port)
  end

  def ready?
    @http.get(__method__, {})
  end

  def group_create(manifest)
    @http.post(__method__, { manifest: manifest })
  end 

  def group_manifest(id)
    @http.get(__method__, { id: id })
  end

  def group_join(id)
    @http.post(__method__, { id: id })
  end

  def group_joined(id)
    @http.get(__method__, { id: id })
  end

  def kata_events(id)
    @http.get(__method__, { id: id })
  end

  def katas_events(ids, indexes)
    @http.get(__method__, { ids: ids, indexes: indexes })
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def kata_file_create(id, index, files, filename)
    @http.post(__method__, { id: id, index: index, files: files, filename: filename })
  end

  def kata_file_delete(id, index, files, filename)
    @http.post(__method__, { id: id, index: index, files: files, filename: filename })
  end

  def kata_file_rename(id, index, files, old_filename, new_filename)
    @http.post(__method__,
    { # rubocop:disable Layout/ArgumentAlignment
      id: id,
      index: index,
      files: files,
      old_filename: old_filename,
      new_filename: new_filename
    })
  end

  def kata_file_switch(id, index, files)
    @http.post(__method__, { id: id, index: index, files: files })
  end

  def kata_ran_tests(id, index, files, stdout, stderr, status, summary)
    @http.post(__method__,
    { # rubocop:disable Layout/ArgumentAlignment
      id: id,
      index: index,
      files: files,
      stdout: stdout,
      stderr: stderr,
      status: status,
      summary: summary
    })
  end
end
