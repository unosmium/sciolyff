# frozen_string_literal: true

require 'minitest/test'
require 'set'

module SciolyFF
  # Tests that also serve as the specification for the sciolyff file format
  #
  class Penalties < Minitest::Test
    def setup
      skip unless SciolyFF.rep.instance_of? Hash
      @penalties = SciolyFF.rep['Penalties']
      skip unless @penalties.instance_of? Array
    end

    def test_has_valid_penalties
      @penalties.each do |penalty|
        assert_instance_of Hash, penalty
      end
    end

    def test_each_penalty_does_not_have_extra_info
      @penalties.select { |p| p.instance_of? Hash }.each do |penalty|
        info = Set.new %w[team points]
        assert Set.new(penalty.keys).subset? info
      end
    end

    def test_each_penalty_has_valid_team
      @penalties.select { |p| p.instance_of? Hash }.each do |penalty|
        assert_instance_of Integer, penalty['team']
        skip unless SciolyFF.rep['Teams'].instance_of? Array

        team_numbers = SciolyFF.rep['Teams'].map { |t| t['number'] }
        assert_includes team_numbers, penalty['team']
      end
    end

    def test_each_penalty_has_valid_points
      @penalties.select { |p| p.instance_of? Hash }.each do |penalty|
        assert_instance_of Integer, penalty['points']
      end
    end
  end
end
