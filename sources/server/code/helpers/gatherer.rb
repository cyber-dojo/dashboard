# frozen_string_literal: true
require_relative '../models/event'
require_relative 'td_gapper'
require_relative 'light'

module AppHelpers # mixin

  module_function

  def gather
    # The new gather function.
    # Uses only the external model service.
    @all_lights = {}
    @all_indexes = {}

    gid = params[:id]
    externals.model.group_joined(gid).each do |index,o|

      lights = o['events'].map{ |event|
        Light.new(event)
      }.select(&:light?)

      unless lights == []
        @all_lights[o['id']] = lights
        @all_indexes[o['id']] = index.to_i
      end
    end
    manifest = externals.model.group_manifest(gid)
    created = Time.mktime(*manifest['created'])
    args = [created, seconds_per_column, max_seconds_uncollapsed]
    gapper = TdGapper.new(*args)
    @gapped = gapper.fully_gapped(@all_lights, time.now)
    @time_ticks = gapper.time_ticks(@gapped)
  end

  def seconds_per_column
    flag = params['minute_columns']
    return 60 if flag.nil? || flag == 'true'
    return 60*60*24*365*1000
  end

  def max_seconds_uncollapsed
    seconds_per_column * 5
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def gather2
    # The original gather function.
    # Does not use external model service.
    @all_lights = {}
    @all_indexes = {}
    e = group.events
    e.each do |kata_id,o|
      kata = katas[kata_id]
      lights = o['events'].each.with_index.map{ |event,index|
        event['index'] = index
        Event.new(kata, event)
      }.select(&:light?)
      unless lights === []
        @all_lights[kata_id] = lights
        @all_indexes[kata_id] = o['index']
      end
    end
    args = [group.created, seconds_per_column, max_seconds_uncollapsed]
    gapper = TdGapper.new(*args)
    @gapped = gapper.fully_gapped(@all_lights, time.now)
    @time_ticks = gapper.time_ticks(@gapped)
  end

end
