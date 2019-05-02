# frozen_string_literal: true

require 'minitest/test'
require 'set'

module SciolyFF
  # Tests that also serve as the specification for the sciolyff file format
  #
  class TopLevelTest < Minitest::Test
    def setup
      @rep = SciolyFF.rep
    end

    def test_has_tournament
      refute_nil @rep['Tournament']
    end

    def test_has_events
      refute_nil @rep['Events']
    end

    def test_has_teams
      refute_nil @rep['Teams']
    end

    def test_has_placings_or_scores
      refute_nil @rep['Placings'] || @rep['Scores']
    end

    def test_has_penalties
      refute_nil @rep['Penalties']
    end

    def test_does_not_have_extra_sections
      sections = Set.new %w[Tournament Events Teams Placings Scores Penalties]
      assert Set.new(@rep.keys).subset? sections
    end
  end
end
