# frozen_string_literal: true

require 'minitest/test'
require 'set'

module SciolyFF
  # Tests that also serve as the specification for the sciolyff file format
  #
  class Placings < Minitest::Test
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

    def test_each_placing_has_valid_participated
      @placings.select { |p| p.instance_of? Hash }.each do |placing|
        if placing.key? 'participated'
          assert_includes [true, false], placing['participated']
        end
      end
    end

    def test_each_placing_has_valid_disqualified
      @placings.select { |p| p.instance_of? Hash }.each do |placing|
        if placing.key? 'disqualified'
          assert_includes [true, false], placing['disqualified']
        end
      end
    end

    def test_each_placing_has_valid_place
      @placings.select { |p| p.instance_of? Hash }.each do |placing|
        next if placing['disqualified'] == true ||
                placing['participated'] == false

        assert_instance_of Integer, placing['place']
        max_place = @placings.count { |p| p['event'] == placing['event'] }
        assert_includes 1..max_place, placing['place']
      end
    end

    def test_placings_are_unique_for_event_and_place
      skip unless SciolyFF.rep['Events'].instance_of? Array

      SciolyFF.rep['Events'].each do |event|
        next unless event.instance_of? Hash

        assert_nil @placings.select { |p| p['event'] == event['name'] }
                            .map { |p| p['place'] }
                            .compact
                            .uniq!
      end
    end

    def test_placings_are_unique_for_event_and_team
      skip unless SciolyFF.rep['Teams'].instance_of? Array

      SciolyFF.rep['Teams'].each do |team|
        next unless team.instance_of? Hash

        assert_nil @placings.select { |p| p['team'] == team['number'] }
                            .map { |p| p['event'] }
                            .compact
                            .uniq!
      end
    end
  end
end
