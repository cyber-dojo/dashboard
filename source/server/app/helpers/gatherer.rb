require_relative 'td_gapper'
require_relative 'event'

# mixin
module GathererHelper
  module_function

  def gather
    @all_lights = {}
    @all_indexes = {}

    gid = params[:id]
    externals.saver.group_joined(gid).each do |avatar_index, o|
      previous_index = 0
      lights = []
      o['events'].each do |event|
        event = Event.new(event, previous_index)
        if visible?(event)
          previous_index = event.index
          lights.append(event)
        end
      end
      unless lights == []
        @all_lights[o['id']] = lights
        @all_indexes[o['id']] = avatar_index.to_i
      end
    end
    manifest = externals.saver.group_manifest(gid)
    created = Time.mktime(*manifest['created'])
    args = [created, seconds_per_column, max_seconds_uncollapsed]
    gapper = TdGapper.new(*args)
    @gapped = gapper.fully_gapped(@all_lights, externals.time.now)
    @time_ticks = gapper.time_ticks(@gapped)
  end

  def visible?(event)
    if detailed?
      true
    else
      event.light?
    end
  end

  def seconds_per_column
    flag = params['minute_columns']
    return 60 if flag.nil? || flag == 'true'

    60 * 60 * 24 * 365 * 1000
  end

  def max_seconds_uncollapsed
    seconds_per_column * 5
  end

  def detailed?
    params['detailed'] == 'true'
  end
end
