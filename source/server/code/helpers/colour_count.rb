
module AppHelpers

  def colour_count(lights, colour)
    lights.count { |light| light.colour == colour }
  end

end
