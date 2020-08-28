# frozen_string_literal: true
#require_relative 'traffic_light_image_path_helper'

module AppHelpers

  module_function

  # The data-id, data-index properties are used to create
  # click handlers that open a diff.
  # The data-tip property is used to create a hover-tip.
  #   see setupHoverTips()
  #   in app/asserts/javascripts/cyber-dojo_hover_tips.js

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def diff_traffic_light(light, avatar_index, number)
    # [1] needed in app/views/kata/edit to count
    # the number of red/amber/green traffic-lights
    [ revert_img_html(light),
      predict_img_html(light),
      "<div class='diff-traffic-light'",
        " data-id='#{light.kata.id}'",
        " data-index='#{light.index}'",
        " data-number='#{number}'",
        " data-avatar-index='#{avatar_index}'",
        " data-colour='#{light.colour}'>", # [1]
        traffic_light_image(light),
      '</div>'
    ].join
  end

  def revert_img_html(light)
    if revert?(light)
      '<img class="revert" src="/images/traffic-light/circle-revert.png">'
    else
      ''
    end
  end

  def revert?(light)
    light.revert
  end

  def predict_img_html(light)
    if predict?(light)
      correct = (light.predicted === light.colour.to_s)
      icon = correct ? 'tick' : 'cross'
      "<img class=\"#{icon}\" src=\"/images/traffic-light/circle-#{icon}.png\">"
    else
      ''
    end
  end

  def predict?(light)
    light.predicted != 'none'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def traffic_light_image(light)
    colour = light.colour
    "<img src='#{traffic_light_image_path(light)}'" +
       " alt='#{colour} traffic-light'/>"
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def traffic_light_image_path(light)
    "/images/traffic-light/#{light.colour}.png"
  end

end
