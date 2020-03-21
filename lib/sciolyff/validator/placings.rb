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
      @event_names = rep[:Events].map { |e| e[:name] }
      @team_numbers = rep[:Teams].map { |t| t[:number] }
      @events_by_name = rep[:Events].group_by { |e| e[:name] }
      @placings = rep[:Placings]
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

    def place_makes_sense?(placing, logger)
      return true unless placing[:place] &&
                         (placing[:participated] == false ||
                          placing[:disqualified] ||
                          placing[:unknown] ||
                          placing[:raw])

      logger.error "place: #{placing[:place]} does not make sense for "\
        "#{placing_log(placing)}"
    end

    def raw_makes_sense?(placing, logger)
      return true unless placing[:raw] &&
                         (placing[:participated] == false ||
                          placing[:disqualified] ||
                          placing[:unknown] ||
                          placing[:place])

      logger.error 'having raw section does not make sense for '\
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
      return true unless placing[:unknown] &&
                         !placing[:exempt] &&
                         !event[:trial] &&
                         !event[:trialed]

      logger.error "unknown place not allowed for #{placing_log(placing)} "\
        '(either placing must be exempt or event must be trial/trialed)'
    end

    private

    def placing_log(placing)
      "placing with 'team: #{placing[:team]}' and 'event: #{placing[:event]}'"
    end
  end
end
