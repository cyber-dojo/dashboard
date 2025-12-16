# frozen_string_literal: true

class Light
  def initialize(summary, previous_index = 0)
    @summary = summary
    @summary['previous_index'] = previous_index
    #@previous_index = previous_index
  end

  def index
    @summary['index']
  end

  def previous_index
    @summary['previous_index']
  end

  def light?
    index != 0 && colour != :""
  end

  def time
    Time.mktime(*time_a)
  end

  def time_a
    @summary['time']
  end

  def predicted
    @summary['predicted'] || 'none'
  end

  def colour
    (@summary['colour'] || '').to_sym
  end

  def revert
    @summary['revert']
  end

  def checkout
    @summary['checkout']
  end
end
