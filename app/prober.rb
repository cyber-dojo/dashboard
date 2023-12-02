# frozen_string_literal: true

# k8s/curl probing + identity
class Prober
  def initialize(externals)
    @externals = externals
  end

  def alive?(_args)
    true
  end

  def ready?(_args)
    saver.ready?
  end

  def sha(_args)
    ENV['SHA']
  end

  private

  def saver
    @externals.saver
  end
end
