require_relative 'service_error'
require 'json'

module HttpJsonHash
  class Unpacker
    def initialize(name, requester)
      @name = name
      @requester = requester
    end

    def get(path, args)
      response = @requester.get(path, args)
      unpacked(response.body, path.to_s, args)
    end

    def post(path, args)
      response = @requester.post(path, args)
      unpacked(response.body, path.to_s, args)
    end

    private

    def unpacked(body, path, args)
      json = JSON.parse!(body)
      service_error(path, args, body, 'body is not JSON Hash') unless json.instance_of?(Hash)
      service_error(path, args, body, 'body has embedded exception') if json.key?('exception')
      service_error(path, args, body, 'body is missing :path key') unless json.key?(path)
      json[path]
    rescue JSON::ParserError
      service_error(path, args, body, 'body is not JSON')
    end

    def service_error(path, args, body, message)
      # puts("XXXX #{path} - #{body} - #{message}")
      raise ::HttpJsonHash::ServiceError.new(path, args, @name, body, message)
    end
  end
end
