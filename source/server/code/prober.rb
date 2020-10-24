# frozen_string_literal: true

class Prober # k8s/curl probing + identity

  def initialize(externals)
    @externals = externals
  end

  def alive?(_args)
    true
  end

  def ready?(_args)
    dependent_services.all?(&:ready?)
  end

  def sha(_args)
    ENV['SHA']
  end

  private

  def dependent_services
    [ @externals.saver ]
  end

end
