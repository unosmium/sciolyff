# frozen_string_literal: true

require 'minitest/test'
require 'set'

module SciolyFF
  # Tests that also serve as the specification for the sciolyff file format
  #
  class TopLevel < Minitest::Test
    def test_is_hash
      assert_instance_of Hash, SciolyFF.rep
    end
  end
end
