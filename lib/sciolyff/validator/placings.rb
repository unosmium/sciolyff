# frozen_string_literal: true

require 'sciolyff/validator/checker'
require 'sciolyff/validator/sections'

module SciolyFF
  # Checks for one placing in the Placings section of a SciolyFF file
  class Validator::Placings < Validator::Checker
    include Validator::Sections

    REQUIRED = {
      event: String,
      team: Integer
    }.freeze

    OPTIONAL = {
      place: Integer,
      participated: [true, false],
      disqualified: [true, false],
      exempt: [true, false],
      tie: [true, false],
      unknown: [true, false],
      raw: Hash
    }.freeze

    def initialize(rep)
      @events_by_name = group(rep[:Events], :name)
      @teams_by_number = group(rep[:Teams], :number)
      @event_names = @events_by_name.keys
      @team_numbers = @teams_by_number.keys
      @placings = rep[:Placings]
      @maximum_place = rep[:Tournament][:'maximum place']
      @has_places = rep[:Placings].any? { |p| p[:place] }
    end

    def matching_event?(placing, logger)
      return true if @event_names.include? placing[:event]

      logger.error "'event: #{placing[:event]}' in Placings "\
        'does not match any event name in Events'
    end

    def matching_team?(placing, logger)
      return true if @team_numbers.include? placing[:team]

      logger.error "'team: #{placing[:team]}' in Placings "\
        'does not match any team number in Teams'
    end

    def unique_event_and_team?(placing, logger)
      return true if @placings.count do |other|
        placing[:event] == other[:event] && placing[:team] == other[:team]
      end == 1

      logger.error "duplicate #{placing_log(placing)}"
    end

    def having_a_place_makes_sense?(placing, logger)
      return true unless placing[:place] &&
                         (placing[:participated] == false ||
                          placing[:disqualified] ||
                          placing[:unknown] ||
                          placing[:raw])

      logger.error 'having a place does not make sense for '\
        "#{placing_log(placing)}"
    end

    def having_a_raw_makes_sense?(placing, logger)
      return true unless placing[:raw] &&
                         (placing[:participated] == false ||
                          placing[:disqualified] ||
                          placing[:unknown] ||
                          placing[:place])

      logger.error 'having raw section does not make sense for '\
        "#{placing_log(placing)}"
    end

    def having_a_tie_makes_sense?(placing, logger)
      return true unless placing.key?(:tie) && placing[:raw]

      logger.error 'having a tie value does make sense for '\
        "#{placing_log(placing)}"
    end

    def possible_participated_disqualified_combination?(placing, logger)
      return true unless placing[:participated] == false &&
                         placing[:disqualified]

      logger.error 'impossible participation-disqualified combination for '\
        "#{placing_log(placing)}"
    end

    def possible_unknown_disqualified_combination?(placing, logger)
      return true unless placing[:unknown] && placing[:disqualified]

      logger.error 'impossible unknown-disqualified combination for '\
        "#{placing_log(placing)}"
    end

    def unknown_allowed?(placing, logger)
      event = @events_by_name[placing[:event]]
      team = @teams_by_number[placing[:team]]
      return true unless invalid_unknown?(placing, event, team)

      logger.error "unknown place not allowed for #{placing_log(placing)} "\
        '(either placing must be exempt or event must be trial/trialed)'
    end

    def no_mix_of_raws_and_places(placing, logger)
      return true unless @has_places && placing.key?(:raw)

      logger.error "cannot mix 'raw:' and 'place:' in same file"
    end

    private

    def placing_log(placing)
      "placing with 'team: #{placing[:team]}' and 'event: #{placing[:event]}'"
    end

    def invalid_unknown?(placing, event, team)
      placing[:unknown] &&
        @maximum_place.nil? &&
        !placing[:exempt] &&
        !event[:trial] &&
        !event[:trialed] &&
        !team[:exhibition]
    end

    def group(arr, key)
      arr.group_by { |e| e[key] }.transform_values(&:first)
    end
  end
end
