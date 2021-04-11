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
    all_lights = []
    all_indexes = []

    gid = params[:id]
    externals.model.group_joined(gid).map do |index,o|

      lights = o['events'].map{ |event|
        Light.new(event)
      }.select(&:light?)

      unless lights == []
        all_ids << o['id']
        all_lights << lights
        all_indexes << index
      end
    end
    manifest = externals.model.group_manifest(gid)
    regexs = manifest['progress_regexs']
    output = '...to do...'
    _matches = regexs.map { |regex| Regexp.new(regex).match(output) }

    # Now need externals.model.katas_events()

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
