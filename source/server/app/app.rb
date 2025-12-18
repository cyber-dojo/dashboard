# frozen_string_literal: true

require_relative 'app_base'
require_relative 'prober'
require_relative 'helpers/gatherer'
require_relative 'helpers/avatars_progress'

class App < AppBase
  def initialize(externals)
    super
    @externals = externals
  end

  attr_reader :externals

  get_delegate(Prober, :alive?)
  get_delegate(Prober, :ready?)
  get_delegate(Prober, :sha)

  get '/show/:id', provides: [:html] do
    @id = params[:id]
    respond_to do |wants|
      wants.html do
        erb :show
      end
    end
  end

  get '/heartbeat/:id', provides: [:json] do
    # Process all traffic-lights into minute columns here in Ruby
    # which can easily handle integers (unlike JS).
    # Then let browser do all rendering in JS.
    respond_to do |wants|
      wants.json do
        gather
        time_ticks = modified(@time_ticks)
        avatars = altered(@all_indexes, @gapped)
        json({ time_ticks: time_ticks, avatars: avatars })
      end
    end
  end

  get '/progress/:id', provides: [:json] do
    respond_to do |wants|
      wants.json do
        json(katas: avatars_progress)
      end
    end
  end

  private

  helpers AvatarsProgressHelper
  helpers GathererHelper

  def altered(indexes, gapped)
    indexes.to_h do |kata_id, group_index|
      [group_index, {
        kata_id: kata_id,
        lights: lights_json(gapped[kata_id])
      }]
    end
  end

  def lights_json(minutes)
    # eg minutes = {
    #     "0": [ L,L,L ],
    #     "1": { "collapsed":525 },
    #   "526": [ L,L ]
    # }
    minutes.transform_values { |value| minute_json(value) }
  end

  def minute_json(minute)
    if collapsed?(minute)
      minute
    else
      minute.map { |light| light_json(light) }
    end
  end

  def collapsed?(section)
    section.is_a?(Hash) # lights are in an Array
  end

  def light_json(light)
    element = {
      previous_index: light.previous_index,
      index: light.index,
      colour: light.colour
    }
    element['predicted'] = light.predicted if light.predicted && light.predicted != 'none'
    element['revert'] = light.revert if light.revert
    element['checkout'] = light.checkout if light.checkout
    element
  end

  def modified(ticks)
    ticks.transform_values do |v|
      dhm(v)
    end
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
end
