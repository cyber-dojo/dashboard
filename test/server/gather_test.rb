require_relative 'test_base'
require_source 'helpers/app_helpers'
require_source 'helpers/gatherer'

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
  'gather from saved cyber-dojo group v0' do
    @params = { id:'chy6BJ' }
    
    gather

    expected = {
      'k5ZTk0' => 11,
    }
    assert_equal expected, @all_indexes
    
    actual = {
      'k5ZTk0' => flat_lights('k5ZTk0'),
    }
    expected = {
      'k5ZTk0' => [
        tcp([2019, 1, 19, 12, 45, 19, 994317], :red,   'none'),
        tcp([2019, 1, 19, 12, 45, 26, 76791],  :amber, 'none'),
        tcp([2019, 1, 19, 12, 45, 30, 656924], :green, 'none'),
      ]
    }
    assert_equal expected, actual
  end
  
  #- - - - - - - - - - - - - - - - - - - - - - - - - - -
  
  test 's47',
  'gather from saved cyber-dojo group v1' do
    @params = { id:'LyQpFr' }

    gather
    
    expected = {
      'rUqcey' => 26,
      '38w9NC' => 27,
    }
    assert_equal expected, @all_indexes
    
    actual = {
      'rUqcey' => flat_lights('rUqcey'),
      '38w9NC' => flat_lights('38w9NC'),
    }
    expected = {
      'rUqcey' => [
        tcp([2020, 11, 30, 14, 6, 39, 366362], :green, 'none'),
        tcp([2020, 11, 30, 14, 6, 53, 941739], :green, 'none')
      ],
      '38w9NC' => [
        tcp([2020, 11, 30, 14, 7, 28, 706554], :red, 'none'),        
      ]
    }
    assert_equal expected, actual
  end
  
  private
  
  def tcp(time_a, colour, predicted)
    {
      'time_a' => time_a,
      'colour' => colour,
      'predicted' => predicted      
    }
  end
  
  def flat_lights(id)
    actual = []
    @all_lights[id].each do |light|
      actual << tcp(light.time_a, light.colour, light.predicted)      
    end
    actual
  end
  
end
