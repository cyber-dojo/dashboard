# frozen_string_literal: true

module AppHelpers # mixin

  module_function

  def avatars_progress
    data = []
    gid = params[:id]
    externals.model.group_joined(gid).map do |avatar_index,o|
      lights = o['events'].select{ |event| event.has_key?('colour') }
      unless lights == []
        data << {
          id: o['id'],
          avatar_index: avatar_index,
          index: most_recent_non_amber_index(lights),
          colour: lights[-1]['colour']
        }
      end
    end
    all_ids = data.map{ |d| d[:id] }
    all_indexes = data.map{ |d| d[:index] }
    katas_events = externals.model.katas_events(all_ids, all_indexes)

    manifest = externals.model.group_manifest(gid)
    regexs = manifest['progress_regexs'].map { |pattern| Regexp.new(pattern) }

    progress = []
    data.each do |d|
      event = katas_events[d[:id]][d[:index].to_s]
      output = event['stdout']['content'] + event['stderr']['content']
      progress << {
          colour: d[:colour].to_sym,
        progress: regexs.map{ |regex| regex.match(output) }.join,
           index: d[:avatar_index].to_i,
              id: d[:id]
      }
    end
    progress
  end

  def most_recent_non_amber_index(lights)
    oldest_non_amber = lights.reverse.find { |light|
      ['red','green'].include?(light['colour'])
    }
    if oldest_non_amber.nil?
      lights[-1]['index']
    else
      oldest_non_amber['index']
    end
  end

end
