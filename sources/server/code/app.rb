# frozen_string_literal: true
require_relative 'app_base'
require_relative 'prober'
require_relative 'helpers/app_helpers'

class App < AppBase

  def initialize(externals)
    super(externals)
    @externals = externals
  end

  attr_reader :externals # TODO: Drop when using model-http-proxy

  get_delegate(Prober, :alive?)
  get_delegate(Prober, :ready?)
  get_delegate(Prober, :sha)

  # - - - - - - - - - - - - - - -

  get '/show/:id', provides:[:html] do
    @id = params[:id]
    respond_to { |wants|
      wants.html {
        group # set @group
        erb :show
      }
    }
  end

  # - - - - - - - - - - - - - - -

  get '/heartbeat/:id', provides:[:json] do
    # Process all traffic-lights into minute columns here in Ruby
    # which can easily handle integers (unlike JS).
    # Then let browser do all rendering in JS.
    respond_to { |wants|
      wants.json {
        gather
        time_ticks = modified(@time_ticks)
        avatars = altered(@all_indexes, @gapped)
        json({time_ticks:time_ticks, avatars:avatars})
      }
    }
  end

  # - - - - - - - - - - - - - - -

  get '/progress/:id', provides:[:json] do
    respond_to { |wants|
      wants.json {
        json(animals:animals_progress)
      }
    }
  end

  private

  helpers AppHelpers

  def altered(indexes, gapped)
    Hash[indexes.map{|kata_id,group_index|
      [group_index, {
        'kata_id':kata_id,
        'lights':lights_json(gapped[kata_id])
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
    if light.checkout
      element['checkout'] = light.checkout
    end
    element
  end

  # - - - - - - - - - - - - - - -

  def modified(ticks)
    ticks.inject({}) { |h, (k, v)| h[k] = dhm(v); h }
  end

  def dhm(value)
    if value.is_a?(Integer)
      time_tick(value)
    else
      value # Hash === collapsed columns
    end
  end

  def time_tick(seconds)
    # Avoiding Javascript integer arithmetic
    minutes = (seconds / 60) % 60
    hours   = (seconds / 60 / 60) % 24
    days    = (seconds / 60 / 60 / 24)
    [days, hours, minutes]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def animals_progress
    group.katas
         .select(&:active?)
         .map { |kata| animal_progress(kata) }
  end

  def animal_progress(kata)
    {   colour: kata.lights[-1].colour,
      progress: most_recent_progress(kata),
         index: kata.avatar_index,
            id: kata.id
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def most_recent_progress(kata)
    non_amber = kata.lights.reverse.find { |light|
      [:red,:green].include?(light.colour)
    }
    if non_amber
      output = non_amber.stdout['content'] + non_amber.stderr['content']
    else
      output = ''
    end

    regexs = kata.manifest.progress_regexs
    matches = regexs.map { |regex| Regexp.new(regex).match(output) }

    {
        text: matches.join,
      colour: (matches[0] != nil ? 'red' : 'green')
    }
  end

end
