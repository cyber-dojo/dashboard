require_relative 'test_base'
require_relative '../data/cyber-dojo/kata_test_data'
require_source 'helpers/gatherer'
require_source 'helpers/avatars_progress'

class AvatarsProgressTest < TestBase

  include AvatarsProgressHelper
  include KataTestData

  attr_reader :params

  test '0D6b46', %w(
  | contract-test v0
  ) do
    @params = { id: V0_GROUP_ID }
    expected = [
      {
        id: 'k5ZTk0',
        avatar_index: 11,
        colour: :green,
        progress: ''
      }
    ]
    actual = avatars_progress
    assert_equal expected, actual
  end

  test '0D6b47', %w(
  | contract-test v1
  ) do
    @params = { id: V1_GROUP_ID }
    expected = [
      {
        id: 'rUqcey',
        avatar_index: 26,
        colour: :green,
        progress: 'OK'
      },
      {
        id: '38w9NC',
        avatar_index: 27,
        colour: :red,
        progress: 'FAILED (failures=4)'
      }
    ]
    actual = avatars_progress
    assert_equal expected, actual
  end
end
