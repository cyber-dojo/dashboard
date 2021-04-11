# frozen_string_literal: true

class Prober # k8s/curl probing + identity

  def initialize(externals)
    @externals = externals
  end

  def alive?(_args)
    true
  end

  def ready?(_args)
    model.ready? and saver.ready?
  end

  def sha(_args)
    ENV['SHA']
  end

  private

  def model
    @externals.model
  end

  def saver
    @externals.saver
  end

end
