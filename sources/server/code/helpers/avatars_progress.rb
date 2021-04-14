# frozen_string_literal: true

module AppHelpers # mixin

  module_function

  def avatars_progress
    all_ids = []
    all_avatar_indexes = []
    all_indexes = []
    all_colours = []

    gid = params[:id]
    externals.model.group_joined(gid).map do |avatar_index,o|
      lights = o['events'].select{ |event| event.has_key?('colour') }
      unless lights == []
        all_ids << o['id']
        all_avatar_indexes << avatar_index
        all_indexes << most_recent_non_amber_index(lights)
        all_colours << lights[-1]['colour']
      end
    end
    katas_events = externals.model.katas_events(all_ids, all_indexes)

    manifest = externals.model.group_manifest(gid)
    regexs = manifest['progress_regexs'].map { |pattern| Regexp.new(pattern) }

    progress = []
    (0...all_ids.size).each do |i|
      id = all_ids[i]
      index = all_indexes[i]
      event = katas_events[id][index.to_s]
      output = event['stdout']['content'] + event['stderr']['content']

      progress << {
          colour: all_colours[i].to_sym,
        progress: regexs.map{ |regex| regex.match(output) }.join,
           index: all_avatar_indexes[i].to_i,
              id: id
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
