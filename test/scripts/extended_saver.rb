# frozen_string_literal: true

def require_source(path)
  require_relative("../../source/app/#{path}")
end

require_source 'external_http'
require_source 'external_saver'

# Some comment
class ExtendedSaver < ExternalSaver
  def initialize
    super(ExternalHttp.new)
  end

  # def ready?
  # def group_manifest(id)
  # def group_joined(id)
  # def katas_events(ids, indexes)

  # TODO: need more here... group_create(), kata_create(), ran_tests(), etc

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
end
