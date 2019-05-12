# frozen_string_literal: true

require 'minitest/test'
require 'set'

module SciolyFF
  # Tests that also serve as the specification for the sciolyff file format
  #
  class Sections < Minitest::Test
    def setup
      @rep = SciolyFF.rep
      skip unless @rep.instance_of? Hash
    end

    def test_has_tournament
      assert_instance_of Hash, @rep[:Tournament]
    end

    def test_has_events
      assert_instance_of Array, @rep[:Events]
    end

    def test_has_teams
      assert_instance_of Array, @rep[:Teams]
    end

    def test_has_placings_or_scores
      assert @rep[:Placings].instance_of?(Array) ||
             @rep[:Scores].instance_of?(Array)
    end

    def test_has_penalties
      assert_instance_of Array, @rep[:Penalties] if @rep.key? :Penalties
    end

    def test_does_not_have_extra_sections
      sections = Set.new %i[Tournament Events Teams Placings Scores Penalties]
      assert Set.new(@rep.keys).subset? sections
    end
  end
end
