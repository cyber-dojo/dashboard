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
    id = 'chy6BJ'
    expected_indexes = {
      'k5ZTk0' => 11,
    }
    expected_lights = {
      'k5ZTk0' => [
        tcp([2019, 1, 19, 12, 45, 19, 994317], :red,   'none'),
        tcp([2019, 1, 19, 12, 45, 26,  76791], :amber, 'none'),
        tcp([2019, 1, 19, 12, 45, 30, 656924], :green, 'none'),
      ]
    }
    @params = { id:id }    
    old_gather_check(expected_indexes, expected_lights)
    new_gather_check(expected_indexes, expected_lights)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 's47',
  'gather from saved cyber-dojo group v1' do
    id = 'LyQpFr'
    expected_indexes = {
      'rUqcey' => 26,
      '38w9NC' => 27,
    }
    expected_lights = {
      'rUqcey' => [
        tcp([2020, 11, 30, 14, 6, 39, 366362], :green, 'none'),
        tcp([2020, 11, 30, 14, 6, 53, 941739], :green, 'none')
      ],
      '38w9NC' => [
        tcp([2020, 11, 30, 14, 7, 28, 706554], :red, 'none'),
      ]
    }
    @params = { id:id }
    old_gather_check(expected_indexes, expected_lights)
    new_gather_check(expected_indexes, expected_lights)    
  end

  def old_gather_check(expected_indexes, expected_lights)
    gather
    assert_equal expected_indexes, @all_indexes
    actual_lights = {}
    expected_indexes.keys.each do |id|
      actual_lights[id] = flat_lights(id)
    end
    assert_equal expected_lights, actual_lights  
  end

  def new_gather_check(expected_indexes, expected_lights)
    gather2
    assert_equal expected_indexes, @all_indexes
    actual_lights = {}
    expected_indexes.keys.each do |id|
      actual_lights[id] = flat_lights(id)
    end
    assert_equal expected_lights, actual_lights      
    #assert_equal expected_lights, @all_lights    
  end

  private

  def gather2
    # Intention is to use this instead of gather() in helpers/gatherer.rb
    # as part of switching away from saver and to model.
    @all_lights = {}
    @all_indexes = {}    
    id = params[:id]
    externals.model.group_joined(id).each do |index,o|
      kata_id = o['id']
      kata = katas[kata_id]
      lights = o['events'].map{ |event| Event.new(kata, event) }.select(&:light?)      
      unless lights == []
        @all_lights[o['id']] = lights
        @all_indexes[o['id']] = index.to_i
      end
    end  
    args = [group.created, seconds_per_column, max_seconds_uncollapsed]
    gapper = TdGapper.new(*args)
    @gapped = gapper.fully_gapped(@all_lights, time.now)
    @time_ticks = gapper.time_ticks(@gapped)
    #set_footer_info    
  end

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
