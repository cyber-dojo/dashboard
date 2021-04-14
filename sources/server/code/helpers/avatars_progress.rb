# frozen_string_literal: true

module AppHelpers # mixin

  module_function

  def avatars_progress
    all_ids = []
    all_indexes = []
    all_avatar_indexes = []
    all_colours = []
    oldest_non_ambers = []

    gid = params[:id]
    externals.model.group_joined(gid).map do |index,o|

      lights = o['events'].select{ |event| event.has_key?('colour') }
      unless lights == []
        all_ids << o['id']
        all_avatar_indexes << index
        all_colours << lights[-1]['colour']
        oldest_non_amber = lights.reverse.find { |light|
          ['red','green'].include?(light['colour'])
        }
        oldest_non_ambers << oldest_non_amber
        if oldest_non_amber.nil?
          all_indexes << lights[-1]['index']
        else
          all_indexes << oldest_non_amber['index']
        end
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

end
