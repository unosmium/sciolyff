# frozen_string_literal: true

require 'minitest/test'
require 'set'

module SciolyFF
  # Tests that also serve as the specification for the sciolyff file format
  #
  class Scores < Minitest::Test
    def setup
      skip unless SciolyFF.rep.instance_of? Hash
      @scores = SciolyFF.rep[:Scores]
      skip unless @scores.instance_of? Array
    end

    def test_has_valid_scores
      @scores.each do |score|
        assert_instance_of Hash, score
      end
    end

    def test_each_score_does_not_have_extra_info
      @scores.select { |s| s.instance_of? Hash }.each do |score|
        a = %i[event team participated disqualified exempt unknown score tier]
        a << :'tiebreaker place'
        info = Set.new a
        assert Set.new(score.keys).subset? info
      end
    end

    def test_each_score_has_valid_event
      @scores.select { |s| s.instance_of? Hash }.each do |score|
        assert_instance_of String, score[:event]
        skip unless SciolyFF.rep[:Events].instance_of? Array

        event_names = SciolyFF.rep[:Events].map { |e| e[:name] }
        assert_includes event_names, score[:event]
      end
    end

    def test_each_score_has_valid_team
      @scores.select { |s| s.instance_of? Hash }.each do |score|
        assert_instance_of Integer, score[:team]
        skip unless SciolyFF.rep[:Teams].instance_of? Array

        team_numbers = SciolyFF.rep[:Teams].map { |t| t[:number] }
        assert_includes team_numbers, score[:team]
      end
    end

    def test_each_score_has_valid_participated
      @scores.select { |s| s.instance_of? Hash }.each do |score|
        if score.key? :participated
          assert_includes [true, false], score[:participated]
        end
      end
    end

    def test_each_score_has_valid_disqualified
      @scores.select { |s| s.instance_of? Hash }.each do |score|
        if score.key? :disqualified
          assert_includes [true, false], score[:disqualified]
        end
      end
    end

    def test_each_score_has_valid_exempt
      @scores.select { |s| s.instance_of? Hash }.each do |score|
        assert_includes [true, false], score[:exempt] if score.key? :exempt
      end
    end

    def test_each_score_has_valid_unknown
      @scores.select { |s| s.instance_of? Hash }.each do |score|
        assert_includes [true, false], score[:unknown] if score.key? :unknown
      end
    end

    def test_each_score_has_valid_score
      @scores.select { |s| s.instance_of? Hash }.each do |score|
        next if score[:disqualified] == true ||
                score.key?(:participated) ||
                placing[:exempt] == true

        assert_kind_of Numeric, score[:score]
      end
    end

    def test_each_score_has_valid_tiebreaker_place
      @scores.select { |s| s.instance_of? Hash }.each do |score|
        next unless score.key? 'tiebreaker place'

        max_place = @scores.count do |s|
          s[:event] == score[:event] &&
            s[:score] == score[:score]
        end
        assert_instance_of Integer, score['tiebreaker place']
        assert_includes 1..max_place, score['tiebreaker place']
      end
    end

    def test_each_score_has_valid_tier
      skip unless SciolyFF.rep[:Events].instance_of? Array

      @scores.select { |s| s.instance_of? Hash }.each do |score|
        next unless score.key? :tier

        assert_instance_of Integer, score[:tier]

        max_tier = SciolyFF.rep[:Events].find do |event|
          event[:name] == score[:event]
        end&.[](:tiers)

        refute_nil max_tier, "#{score[:event]} does not have tiers"
        assert_includes 1..max_tier, score[:tier]
      end
    end

    def test_scores_are_unique_for_event_and_team
      skip unless SciolyFF.rep[:Teams].instance_of? Array

      SciolyFF.rep[:Teams].each do |team|
        next unless team.instance_of? Hash

        assert_nil @scores.select { |s| s[:team] == team[:number] }
                          .map { |s| s[:event] }
                          .compact
                          .uniq!
      end
    end

    def test_each_team_has_scores_for_all_events
      skip unless SciolyFF.rep[:Teams].instance_of?(Array) &&
                  SciolyFF.rep[:Events].instance_of?(Array)

      SciolyFF.rep[:Teams].select { |t| t.instance_of? Hash }.each do |team|
        events = SciolyFF.rep[:Events].select { |e| e.instance_of? Hash }
                         .map { |e| e[:name] }

        events_with_scores = @scores.select { |s| s.instance_of? Hash }
                                    .select { |s| s[:team] == team[:number] }
                                    .map { |s| s[:event] }

        assert_equal events, events_with_scores
      end
    end
  end
end
