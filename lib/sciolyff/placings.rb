# frozen_string_literal: true

require 'minitest/test'
require 'set'

module SciolyFF
  # Tests that also serve as the specification for the sciolyff file format
  #
  class Placings < Minitest::Test
    def setup
      skip unless SciolyFF.rep.instance_of? Hash
      @placings = SciolyFF.rep[:Placings]
      skip unless @placings.instance_of? Array
    end

    def test_has_valid_placings
      @placings.each do |placing|
        assert_instance_of Hash, placing
      end
    end

    def test_each_placing_does_not_have_extra_info
      @placings.select { |p| p.instance_of? Hash }.each do |placing|
        info = Set.new %i[event team participated disqualified exempt place tie]
        info << :unknown
        assert Set.new(placing.keys).subset? info
      end
    end

    def test_each_placing_has_valid_event
      @placings.select { |p| p.instance_of? Hash }.each do |placing|
        assert_instance_of String, placing[:event]
        skip unless SciolyFF.rep[:Events].instance_of? Array

        event_names = SciolyFF.rep[:Events].map { |e| e[:name] }
        assert_includes event_names, placing[:event]
      end
    end

    def test_each_placing_has_valid_team
      @placings.select { |p| p.instance_of? Hash }.each do |placing|
        assert_instance_of Integer, placing[:team]
        skip unless SciolyFF.rep[:Teams].instance_of? Array

        team_numbers = SciolyFF.rep[:Teams].map { |t| t[:number] }
        assert_includes team_numbers, placing[:team]
      end
    end

    def test_each_placing_has_valid_participated
      @placings.select { |p| p.instance_of? Hash }.each do |placing|
        if placing.key? :participated
          assert_includes [true, false], placing[:participated]
        end
      end
    end

    def test_each_placing_has_valid_disqualified
      @placings.select { |p| p.instance_of? Hash }.each do |placing|
        if placing.key? :disqualified
          assert_includes [true, false], placing[:disqualified]
        end
      end
    end

    def test_each_placing_has_valid_exempt
      @placings.select { |p| p.instance_of? Hash }.each do |placing|
        assert_includes [true, false], placing[:exempt] if placing.key? :exempt
      end
    end

    def test_each_team_has_correct_number_of_exempt_placings
      skip unless SciolyFF.rep.instance_of? Hash
      skip unless SciolyFF.rep[:Tournament].instance_of? Hash

      exempt_placings = SciolyFF.rep[:Tournament][:'exempt placings']
      exempt_placings = 0 if exempt_placings.nil?
      skip unless exempt_placings.instance_of? Integer

      @placings.select { |p| p.instance_of?(Hash) && p[:'exempt'] }
               .group_by { |p| p[:team] }
               .each do |team_number, placings|
        assert placings.count == exempt_placings,
               "Team number #{team_number} has the incorrect number of exempt "\
               "placings (#{placings.count} instead of #{exempt_placings})"
      end
    end

    def test_each_placing_has_valid_tie
      @placings.select { |p| p.instance_of? Hash }.each do |placing|
        next unless placing.key? :tie

        assert_includes [true, false], placing[:tie]
        next unless placing[:tie]

        all_paired = @placings.select do |p_other|
          p_other.instance_of?(Hash) &&
            p_other != placing &&
            p_other[:event] == placing[:event] &&
            p_other[:place] == placing[:place]
        end.all? { |p_other| p_other[:tie] }

        assert all_paired,
               "The event #{placing[:event]} has unpaired ties at "\
               "#{placing[:place]}"
      end
    end

    def test_each_placing_has_valid_unknown
      skip if SciolyFF.rep[:Tournament]&.key? :'maximum place'

      @placings.select { |p| p.instance_of? Hash }.each do |placing|
        next unless placing.key? :unknown

        assert_includes [true, false], placing[:unknown]
        next unless placing[:unknown]

        skip unless SciolyFF.rep[:Events].instance_of? Array

        event = SciolyFF.rep[:Events].find do |e|
          e[:name] == placing[:event]
        end
        assert event[:trial] || event[:trialed] || placing[:exempt],
               'Cannot have unknown place for non-trial/trialed event '\
               'or non-exempt place'
      end
    end

    def test_each_placing_has_valid_place
      @placings.select { |p| p.instance_of? Hash }.each do |placing|
        next if placing[:disqualified] == true ||
                placing.key?(:participated) ||
                placing[:unknown] == true ||
                placing[:exempt] == true

        assert_instance_of Integer, placing[:place]
        max_place = @placings.count do |p|
          p[:event] == placing[:event] &&
            !p[:disqualified] &&
            p[:participated] != false
        end
        assert_includes 1..max_place, placing[:place],
                        "The event #{placing[:event]} "\
                        'has an out-of-range placing'
      end
    end

    def test_placings_are_unique_for_event_and_place
      skip unless SciolyFF.rep[:Events].instance_of? Array

      SciolyFF.rep[:Events].each do |event|
        next unless event.instance_of? Hash

        places = @placings.select { |p| p[:event] == event[:name] }
                          .reject { |p| p[:tie] }
                          .map { |p| p[:place] }
                          .compact

        dups = places.select.with_index do |p, i|
          places.index(p) != i
        end

        assert_empty dups,
                     "The event #{event[:name]} has unmarked ties at #{dups}"
      end
    end

    def test_placings_are_unique_for_event_and_team
      skip unless SciolyFF.rep[:Teams].instance_of? Array

      SciolyFF.rep[:Teams].each do |team|
        next unless team.instance_of? Hash

        assert_nil @placings.select { |p| p[:team] == team[:number] }
                            .map { |p| p[:event] }
                            .compact
                            .uniq!
      end
    end

    def test_each_team_has_placings_for_all_events
      skip unless SciolyFF.rep[:Teams].instance_of?(Array) &&
                  SciolyFF.rep[:Events].instance_of?(Array)

      SciolyFF.rep[:Teams].select { |t| t.instance_of? Hash }.each do |team|
        events = SciolyFF.rep[:Events].select { |e| e.instance_of? Hash }
                         .map { |e| e[:name] }

        events_with_placings =
          @placings.select { |p| p.instance_of? Hash }
                   .select { |p| p[:team] == team[:number] }
                   .map { |p| p[:event] }

        assert_equal events.sort, events_with_placings.sort
      end
    end
  end
end
