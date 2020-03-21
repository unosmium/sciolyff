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
      @events = rep[:Events].map { |e| e[:name] }
      @teams = rep[:Teams].map { |t| t[:number] }
      @placings = rep[:Placings]
    end

    def matching_event?(placing, logger)
      return true if @events.include? placing[:event]

      logger.error "'event: #{placing[:event]}' in Placings "\
        'does not match any event name in Events'
    end

    def matching_team?(placing, logger)
      return true if @teams.include? placing[:team]

      logger.error "'team: #{placing[:team]}' in Placings "\
        'does not match any team number in Teams'
    end

    def unique_event_and_team?(placing, logger)
      return true if @placings.count do |other|
        placing[:event] == other[:event] && placing[:team] == other[:team]
      end == 1

      logger.error "duplicate placing with 'team: #{placing[:team]}' "\
        "and 'event: #{placing[:event]}'"
    end
  end
end
