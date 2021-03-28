require_relative 'test_base'
require_source 'models/groups'

class GroupEventsTest < TestBase

  def self.id58_prefix
    '47Y'
  end

  include AppHelpers

  def params
    @params
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Intention: add a group_events() method to the model service API.
  # Then run this as a contract-style test to test it has
  # the same behaviour group.events() implemented in the model
  # code duplicated in this dashboard repo.
  # Then switch to using model.group_events()

  test 'G73',
  'group_events from saved cyber-dojo group v0' do

    @params = { id:'chy6BJ' }

    events = group.events

    expected = {
      'k5ZTk0' => {
        "index" => 11,
        "events" => [
          {
            "event" => "created",
            "time" => [2019, 1, 19, 12, 41, 0, 406370],
          },
          {
            "colour" => "red",
            "time" => [2019, 1, 19, 12, 45, 19, 994317],
            "duration" => 1.224763,
          },
          {
            "colour" => "amber",
            "time" => [2019, 1, 19, 12, 45, 26, 76791],
            "duration" => 1.1275,
          },
          {
            "colour" => "green",
            "time" => [2019, 1, 19, 12, 45, 30, 656924],
            "duration" => 1.072198,
          }
        ]
      }
    }

    assert_equal expected, events
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'G74',
  'group_events from saved cyber-dojo group v1' do

    @params = { id:'LyQpFr' }

    events = group.events

    expected = {
      'rUqcey' => {
        "index" => 26,
        "events" => [
          {
            "index" => 0,
            "time" => [2020, 11, 30, 14, 6, 28, 776722],
            "event" => "created",
          },
          {
            "index" => 1,
            "colour" => "green",
            "predicted" => "none",
            "time" => [2020, 11, 30, 14, 6, 39, 366362],
            "duration" => 2.726096,
          },
          {
            "index" => 2,
            "colour" => "green",
            "predicted" => "none",
            "time" => [2020, 11, 30, 14, 6, 53, 941739],
            "duration" => 1.891786,
          }
        ]
      },
      '38w9NC' => {
        "index" => 27,
        "events" => [
          {
            "index" => 0,
            "time" => [2020, 11, 30, 14, 7, 11, 11464],
            "event" => "created"
          },
          {
            "index" => 1,
            "colour" => "red",
            "predicted" => "none",
            "time" => [2020, 11, 30, 14, 7, 28, 706554],
            "duration" => 1.199071,
          }
        ]
      }
    }

    assert_equal expected, events
  end

end
