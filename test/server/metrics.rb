# frozen_string_literal: true

# Values are low; legacy models/ code is being phased
# out in favour of external.saver micro-service.

# max values used by cyberdojo/check-test-results image
# which is called from sh/test_in_containers.sh

MAX = {
  failures: 0,
  errors: 0,
  warnings: 1,
  skips: 0,

  duration: 10,

  app: {
    lines: {
      total: 388,
      missed: 95
    },
    branches: {
      total: 50,
      missed: 25
    }
  },

  test: {
    lines: {
      total: 528,
      missed: 0
    },
    branches: {
      total: 0,
      missed: 0
    }
  }
}.freeze
