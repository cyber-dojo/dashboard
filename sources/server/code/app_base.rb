# frozen_string_literal: true
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
    super(nil)
  end

  silently { register Sinatra::Contrib }
  set :port, ENV['PORT']
  set :environment, Sprockets::Environment.new

  # - - - - - - - - - - - - - - - - - - - - - -

  environment.append_path('code/assets/images')

  def self.jquery_dialog_image(name)
    get "/assets/images/#{name}", provides:[:png] do
      env['PATH_INFO'].sub!('/assets/images', '')
      settings.environment.call(env)
    end
  end

  jquery_dialog_image('ui-icons_222222_256x240.png')
  jquery_dialog_image('ui-icons_ffffff_256x240.png')
  jquery_dialog_image('ui-bg_diagonals-thick_20_666666_40x40.png')

  # - - - - - - - - - - - - - - - - - - - - - -

  environment.append_path('code/assets/stylesheets')
  environment.css_compressor = :sassc

  get '/assets/app.css', provides:[:css] do
    respond_to do |format|
      format.css do
        env['PATH_INFO'].sub!('/assets', '')
        settings.environment.call(env)
      end
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  environment.append_path('code/assets/javascripts')
  environment.js_compressor  = Uglifier.new(harmony: true)

  get '/assets/app.js', provides:[:js] do
    respond_to do |format|
      format.js do
        env['PATH_INFO'].sub!('/assets', '')
        settings.environment.call(env)
      end
    end
  end

  private

  def self.get_delegate(klass, name)
    get "/#{name}", provides:[:json] do
      respond_to do |format|
        format.json {
          target = klass.new(@externals)
          result = target.public_send(name, params)
          json({ name => result })
        }
      end
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def json_args
    symbolized(json_payload)
  end

  def symbolized(h)
    # named-args require symbolization
    Hash[h.map{ |key,value| [key.to_sym, value] }]
  end

  def json_payload
    json_hash_parse(request.body.read)
  end

  def json_hash_parse(body)
    json = (body === '') ? {} : JSON.parse!(body)
    unless json.instance_of?(Hash)
      fail 'body is not JSON Hash'
    end
    json
  rescue JSON::ParserError
    fail 'body is not JSON'
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  set :show_exceptions, false

  error do
    error = $!
    status(500)
    content_type('application/json')
    info = {
      exception: {
        request: {
          path:request.path,
          body:request.body.read
        },
        backtrace: error.backtrace
      }
    }
    exception = info[:exception]
    if error.instance_of?(::HttpJsonHash::ServiceError)
      exception[:http_service] = {
        path:error.path,
        args:error.args,
        name:error.name,
        body:error.body,
        message:error.message
      }
    else
      exception[:message] = error.message
    end
    diagnostic = JSON.pretty_generate(info)
    puts diagnostic
    body diagnostic
  end

end
