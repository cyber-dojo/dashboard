# frozen_string_literal: true

class Light
  def initialize(summary, previous_index = nil)
    @summary = summary
    if previous_index.nil?
      @previous_index = index - 1
    else
      @previous_index = previous_index
    end
  end

  def index
    @summary['index']
  end

  def previous_index
    @previous_index
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
    index != 0 && colour != :""
  end

  def revert
    @summary['revert']
  end

  def checkout
    @summary['checkout']
  end
end
