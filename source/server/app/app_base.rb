# frozen_string_literal: true

require 'English'

require_relative 'silently'
require 'sinatra/base'
silently { require 'sinatra/contrib' } # N x "warning: method redefined"
require_relative 'http_json_hash/service'
require 'json'
require 'sprockets'
require 'uglifier'

class AppBase < Sinatra::Base
  def initialize(externals)
    @externals = externals
    @css = File.read("#{__dir__}/assets/stylesheets/pre-built-app.css")
    super(nil)
  end

  silently { register Sinatra::Contrib }
  set :port, ENV.fetch('PORT', nil)
  set :environment, Sprockets::Environment.new

  environment.append_path('app/assets/images')

  def self.jquery_dialog_image(name)
    get "/assets/images/#{name}", provides: [:png] do
      env['PATH_INFO'].sub!('/assets/images', '')
      settings.environment.call(env)
    end
  end

  jquery_dialog_image('ui-icons_222222_256x240.png')
  jquery_dialog_image('ui-icons_ffffff_256x240.png')
  jquery_dialog_image('ui-bg_diagonals-thick_20_666666_40x40.png')

  get '/assets/app.css', provides: [:css] do
    respond_to do |format|
      format.css do
        @css
      end
    end
  end

  environment.append_path('app/assets/javascripts')
  environment.js_compressor = Uglifier.new(harmony: true)

  get '/assets/app.js', provides: [:js] do
    respond_to do |format|
      format.js do
        env['PATH_INFO'].sub!('/assets', '')
        settings.environment.call(env)
        #File.read('/dashboard/app/assets/javascripts/pre-built-app.js')
      end
    end
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
