require_relative 'colour_count'

module AppHelpers

  module_function

  def traffic_light_count(lights)
    "<div class='traffic-light-count-wrapper'>" +
      "<div class='traffic-light-count #{lights[-1].colour}'" +
          " data-tip='traffic_light_count'" +
          " data-red-count='#{colour_count(lights, :red)}'" +
          " data-amber-count='#{colour_count(lights, :amber)}'" +
          " data-green-count='#{colour_count(lights, :green)}'" +
          " data-timed-out-count='#{colour_count(lights, :timed_out)}'>" +
        lights.count.to_s +
      '</div>' +
    '</div>'
  end

end
