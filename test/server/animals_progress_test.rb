require_relative 'test_base'
require_relative '../data/cyber-dojo/kata_test_data'
require_source 'helpers/app_helpers'

class AnimalsProgressTest < TestBase

  def self.id58_prefix
    '0D6'
  end

  include AppHelpers

  def params
    @params
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'b46',
  'contract-test for animals_progress v0' do
    @params = { id:V0_GROUP_ID }
    expected = [
      {
        :colour => :green,
        :progress => {
          :text => "",
          :colour => "green"
        },
        :index => 11,
        :id => "k5ZTk0"
      }
    ]
    actual = animals_progress
    animals_progress_check(expected, actual)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'b47',
  'contract-test for animals_progress v1' do
    @params = { id:V1_GROUP_ID }
    expected = [
      {
        :colour => :green,
        :progress => {
          :text => "OK",
          :colour => "green"
        },
        :index => 26,
        :id => "rUqcey"
      },
      {
        :colour => :red,
        :progress => {
          :text => "FAILED (failures=4)",
          :colour => "red"
        },
        :index => 27,
        :id => "38w9NC"
      }
    ]
    actual = animals_progress
    animals_progress_check(expected, actual)
  end

  private

  include KataTestData

  def animals_progress_check(expected, actual)
    assert_equal expected, actual
  end

end
