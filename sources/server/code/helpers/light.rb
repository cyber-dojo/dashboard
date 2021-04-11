# frozen_string_literal: true

class Light

  def initialize(summary)
    @summary = summary
  end

  def index
    @summary['index']
  end

  def time_a
    @summary['time']
  end

  def time
    Time.mktime(*time_a)
  end

  def predicted
    @summary['predicted'] || 'none'
  end

  def colour
    (@summary['colour'] || '').to_sym
  end

  def light?
    colour != :""
  end

end
