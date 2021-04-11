# frozen_string_literal: true

module AppHelpers # mixin

  module_function

  def animals_progress
    group.katas
         .select(&:active?)
         .map { |kata| animal_progress(kata) }
  end

  def animals_progress2
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
    _regexs = manifest['progress_regexs']

    #_matches = regexs.map { |regex| Regexp.new(regex).match(output) }

    #katas.map { |kata| animal_progress(kata) }

    animals_progress
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
