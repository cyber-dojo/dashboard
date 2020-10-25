# frozen_string_literal: true
require_relative 'app_base'
require_relative 'prober'
require_relative 'helpers/app_helpers'

class App < AppBase

  def initialize(externals)
    super(externals)
    @externals = externals
  end

  attr_reader :externals

  get_delegate(Prober, :alive?)
  get_delegate(Prober, :ready?)
  get_delegate(Prober, :sha)

  get '/show/:id', provides:[:html] do
    respond_to { |wants|
      wants.html {
        gather
        if false
          p "@gapped " + ('~'*60)
          print JSON.pretty_generate(@gapped)
          p "@all_lights " + ('~'*60)
          print JSON.pretty_generate(@all_lights)
          p "@all_indexes " + ('~'*60)
          print JSON.pretty_generate(@all_indexes)
          p "@time_ticks " + ('~'*60)
          print JSON.pretty_generate(@time_ticks)
        end
        erb :show
      }
    }
  end

  get '/heartbeat', provides:[:json] do
    respond_to { |wants|
      wants.json {
        gather
        time_ticks = modified(@time_ticks)
        json({'time_ticks':time_ticks})
      }
    }
  end

  private

  helpers AppHelpers

  def modified(ticks)
    ticks.inject({}) { |h, (k, v)| h[k] = dhm(v); h }
  end

  def dhm(value)
    if value.is_a?(Integer)
      time_tick2(value)
    else
      value # Hash === collapsed columns
    end
  end

  def time_tick2(seconds)
    # Avoiding Javascript integer arithmetic 
    minutes = (seconds / 60) % 60
    hours   = (seconds / 60 / 60) % 24
    days    = (seconds / 60 / 60 / 24)
    [days, hours, minutes]
  end

end
