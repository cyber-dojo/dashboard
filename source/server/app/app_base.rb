require 'English'
require_relative 'silently'
require 'sinatra/base'
silently { require 'sinatra/contrib' } # N x "warning: method redefined"
require_relative 'http_json_hash/service'
require 'json'
require 'digest'

class AppBase < Sinatra::Base
  # Compiled assets live in ${APP_DIR}/assets, a sibling of source/, populated
  # by the Dockerfile from the asset_builder stage, which keeps the precompiled
  # app.css/app.js out of the repo tree.
  ASSETS_DIR = "#{ENV.fetch('APP_DIR')}/assets".freeze

  # Returns the public URL path for a compiled asset, fingerprinted with a short
  # hash of its content, eg "/assets/app-1a2b3c4d.css". Embedding the hash in the
  # path gives each version a unique URL, so it can be cached immutably for a
  # year; browsers then serve it from cache instead of re-pulling it on every
  # page navigation through nginx's rate-limited /dashboard/ zone (which
  # previously tripped a 429).
  def self.asset_path(filename)
    src  = "#{ASSETS_DIR}/#{filename}"
    hash = Digest::SHA256.file(src).hexdigest[0, 8]
    base = File.basename(filename, '.*')
    ext  = File.extname(filename)
    "/assets/#{base}-#{hash}#{ext}"
  end

  CSS_PATH = asset_path('app.css')
  JS_PATH  = asset_path('app.js')

  # Wires the app to its collaborators (saver, differ).
  def initialize(externals)
    @externals = externals
    super(nil)
  end

  silently { register Sinatra::Contrib }
  set :port, ENV.fetch('PORT', nil)

  # Permit all Host headers; nginx fronts this app and validates Host. Without
  # this, Sinatra's development-mode host authorization rejects any Host that is
  # not localhost/.test (eg Rack::Test's example.org) with 'Host not permitted'.
  set :host_authorization, {}

  # - - - - - - - - - - - - - - - -
  # Assets

  get CSS_PATH do
    cache_control :public, max_age: 31_536_000, immutable: true
    content_type 'text/css'
    send_file "#{ASSETS_DIR}/app.css"
  end

  get JS_PATH do
    cache_control :public, max_age: 31_536_000, immutable: true
    content_type 'text/javascript'
    send_file "#{ASSETS_DIR}/app.js"
  end

  private

  def self.get_delegate(klass, name)
    get "/#{name}", provides: [:json] do
      respond_to do |format|
        format.json do
          target = klass.new(@externals)
          result = target.public_send(name, params)
          json({ name => result })
        end
      end
    end
  end

  def json_args
    symbolized(json_payload)
  end

  def symbolized(h)
    # named-args require symbolization
    h.transform_keys(&:to_sym)
  end

  def json_payload
    request.body.rewind
    json_hash_parse(request.body.read)
  end

  def json_hash_parse(body)
    json = body === '' ? {} : JSON.parse!(body)
    raise 'body is not JSON Hash' unless json.instance_of?(Hash)

    json
  rescue JSON::ParserError
    raise 'body is not JSON'
  end

  set :show_exceptions, false

  error do
    error = $ERROR_INFO
    status(500)
    content_type('application/json')
    info = {
      exception: {
        request: {
          path: request.path,
          body: request.body.read
        },
        backtrace: error.backtrace
      }
    }
    exception = info[:exception]
    if error.instance_of?(::HttpJsonHash::ServiceError)
      exception[:http_service] = {
        path: error.path,
        args: error.args,
        name: error.name,
        body: error.body,
        message: error.message
      }
    else
      exception[:message] = error.message
    end
    diagnostic = JSON.pretty_generate(info)
    puts diagnostic
    body diagnostic
  end
end
