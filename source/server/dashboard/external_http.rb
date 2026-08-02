require 'net/http'

module DashboardApp
  class ExternalHttp
    def get(uri)
      KLASS::Get.new(uri)
    end

    # :nocov: post is called only by the fixture scripts in test/scripts
    def post(uri)
      KLASS::Post.new(uri)
    end
    # :nocov:

    def start(hostname, port, req)
      KLASS.start(hostname, port) do |http|
        http.request(req)
      end
    end

    KLASS = Net::HTTP
  end
end
