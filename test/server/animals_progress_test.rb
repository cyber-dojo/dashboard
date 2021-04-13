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
        :id => "k5ZTk0",
        :index => 11,
        :colour => :green,
        :progress => "",
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
        :id => "rUqcey",
        :index => 26,
        :colour => :green,
        :progress => "OK",
      },
      {
        :id => "38w9NC",
        :index => 27,
        :colour => :red,
        :progress => "FAILED (failures=4)",
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
