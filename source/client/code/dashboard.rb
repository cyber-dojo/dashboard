# frozen_string_literal: true

class Dashboard

  def initialize(externals)
    @externals = externals
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def ready?
    creator.ready?
  end

  private

  def dashboard
    @externals.dashboard
  end

end
