require_relative 'test_base'
require_source 'helpers/app_helpers'

class GatheredTest < TestBase

  def self.id58_prefix
    '450'
  end

  include AppHelpers

  def params
    @params
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 's46',
  'contract-test for gather from saved cyber-dojo group v0' do
    id = 'chy6BJ'
    expected_indexes = {
      'k5ZTk0' => 11,
    }
    expected_lights = {
      'k5ZTk0' => [
        tcpi([2019, 1, 19, 12, 45, 19, 994317], :red,   'none', 1),
        tcpi([2019, 1, 19, 12, 45, 26,  76791], :amber, 'none', 2),
        tcpi([2019, 1, 19, 12, 45, 30, 656924], :green, 'none', 3),
      ]
    }
    @params = { id:id }
    gather
    gather_check(expected_indexes, expected_lights)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 's47',
  'contract-test for gather from saved cyber-dojo group v1' do
    id = 'LyQpFr'
    expected_indexes = {
      'rUqcey' => 26,
      '38w9NC' => 27,
    }
    expected_lights = {
      'rUqcey' => [
        tcpi([2020, 11, 30, 14, 6, 39, 366362], :green, 'none', 1),
        tcpi([2020, 11, 30, 14, 6, 53, 941739], :green, 'none', 2)
      ],
      '38w9NC' => [
        tcpi([2020, 11, 30, 14, 7, 28, 706554], :red, 'none', 1),
      ]
    }
    @params = { id:id }
    gather
    gather_check(expected_indexes, expected_lights)
  end

  private

  def gather_check(expected_indexes, expected_lights)
    assert_equal expected_indexes, @all_indexes
    actual_lights = {}
    expected_indexes.keys.each do |id|
      actual_lights[id] = flat_lights(id)
    end
    assert_equal expected_lights, actual_lights
  end

  def tcpi(time_a, colour, predicted, index)
    {
      'time_a' => time_a,
      'colour' => colour,
      'predicted' => predicted,
      'index' => index
    }
  end

  def flat_lights(id)
    actual = []
    @all_lights[id].each do |light|
      actual << tcpi(
        light.time_a,
        light.colour,
        light.predicted,
        light.index
      )
    end
    actual
  end

end
