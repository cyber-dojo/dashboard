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

  get '/show', provides:[:html] do
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
        avatars = altered(@all_indexes, @gapped)
        json({'time_ticks':time_ticks, 'avatars':avatars})
      }
    }
  end

  private

  helpers AppHelpers

  def altered(indexes, gapped)
    Hash[indexes.map{|kata_id,group_index|
      [group_index, {
        "kata_id":kata_id,
        "lights":lights_json(gapped[kata_id])
      }]
    }]
  end

  def lights_json(minutes)
    # eg minutes = {
    #     "0": [ L,L,L ],
    #     "1": { "collapsed":525 },
    #   "526": [ L,L ]
    # }
    Hash[minutes.map{|key,value| [key,minute_json(value)] }]
  end

  def minute_json(minute)
    if !collapsed?(minute)
      minute.map{|light| light_json(light)}
    else
      minute
    end
  end

  def collapsed?(section)
    section.is_a?(Hash) # lights are in an Array
  end

  def light_json(light)
    element = {
      'index':light.index,
      'colour':light.colour
    }
    if light.predicted && light.predicted != 'none'
      element['predicted'] = light.predicted
    end
    if light.revert
      element['revert'] = light.revert
    end
    element
  end

  # - - - - - - - - - - - - - - -

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
