# frozen_string_literal: true

require 'minitest/test'
require 'set'

module SciolyFF
  # Tests that also serve as the specification for the sciolyff file format
  #
  class PlacingsTest < Minitest::Test
    def setup
      skip unless SciolyFF.rep.instance_of? Hash
      @placings = SciolyFF.rep['Placings']
      skip unless @placings.instance_of? Array
    end

    def test_has_valid_placings
      @placings.each do |placing|
        assert_instance_of Hash, placing
      end
    end

    def test_each_placing_does_not_have_extra_info
      @placings.select { |p| p.instance_of? Hash }.each do |placing|
        info = Set.new %w[event team participated disqualified place]
        assert Set.new(placing.keys).subset? info
      end
    end

    def test_each_placing_has_valid_event
      @placings.select { |p| p.instance_of? Hash }.each do |placing|
        assert_instance_of String, placing['event']
        event_names = SciolyFF.rep['Events'].map { |e| e['name'] }
        assert_includes event_names, placing['event']
      end
    end

    def test_each_placing_has_valid_team
      @placings.select { |p| p.instance_of? Hash }.each do |placing|
        assert_instance_of Integer, placing['team']
        team_numbers = SciolyFF.rep['Teams'].map { |t| t['number'] }
        assert_includes team_numbers, placing['team']
      end
    end
  end
end
