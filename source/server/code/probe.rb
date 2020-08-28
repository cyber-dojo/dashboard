# frozen_string_literal: true

class Probe

  def initialize(externals)
    @externals = externals
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # k8s/curl probing + identity

  def alive?
    true
  end

  def ready?
    dependent_services.all?(&:ready?)
  end

  def sha
    ENV['SHA']
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  private

  def dependent_services
    [ saver ]
  end

  def saver
    @externals.saver
  end

end
