# frozen_string_literal: true
require_relative '../externals'

class Avatars

  def self.names
    # self.new to create object to get avatars from Externals
    @@names ||= Externals.new.avatars.names
  end

  def self.index(name)
    self.names.index(name)
  end

end
