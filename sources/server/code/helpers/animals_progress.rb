# frozen_string_literal: true

module AppHelpers # mixin

  module_function

  def animals_progress
    # The new animals_progress function.
    # Uses only the external model service.
    all_ids = []
    all_indexes = []
    all_avatar_indexes = []
    all_colours = []
    all_outputs = []
    oldest_non_ambers = []

    gid = params[:id]
    externals.model.group_joined(gid).map do |index,o|

      lights = o['events'].select{ |event| event['colour'] != '' }
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
    (0...all_ids.size).each do |i|
      id = all_ids[i]
      index = all_indexes[i]
      event = katas_events[id][index.to_s]
      output = event['stdout']['content'] + event['stderr']['content']
      all_outputs << output
    end

    manifest = externals.model.group_manifest(gid)
    regexs = manifest['progress_regexs']

    result = []
    (0...all_ids.size).each do |i|
      id = all_ids[i]
      avatar_index = all_avatar_indexes[i]
      colour = all_colours[i]
      output = all_outputs[i]
      result << animal_progress(regexs, id, avatar_index, colour, output)
    end
    result
  end

  def animal_progress(regexs, id, avatar_index, colour, output)
    {
        colour: colour.to_sym,
      progress: most_recent_progress(regexs, output),
         index: avatar_index.to_i,
            id: id
    }
  end

  def most_recent_progress(regexs, output)
    matches = regexs.map { |regex| Regexp.new(regex).match(output) }
    matches.join
  end

end
