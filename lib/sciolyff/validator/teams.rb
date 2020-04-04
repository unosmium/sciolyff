# frozen_string_literal: true

require 'sciolyff/validator/checker'
require 'sciolyff/validator/sections'

module SciolyFF
  # Checks for one team in the Teams section of a SciolyFF file
  class Validator::Teams < Validator::Checker
    include Validator::Sections

    REQUIRED = {
      number: Integer,
      school: String,
      state: String
    }.freeze

    OPTIONAL = {
      'school abbreviation': String,
      subdivision: String,
      suffix: String,
      city: String,
      disqualified: [true, false],
      exhibition: [true, false]
    }.freeze

    def initialize(rep)
      @teams = rep[:Teams]
      @numbers = @teams.map { |t| t[:number] }
      @schools = @teams.group_by { |t| [t[:school], t[:city], t[:state]] }
      @placings = rep[:Placings].group_by { |p| p[:team] }
      @exempt = rep[:Tournament][:'exempt placings'] || 0
    end

    def unique_number?(team, logger)
      return true if @numbers.count(team[:number]) == 1

      logger.error "duplicate team number: #{team[:number]}"
    end

    def unique_suffix_per_school?(team, logger)
      full_school = [team[:school], team[:city], team[:state]]
      return true if @schools[full_school].count do |other|
        !other[:suffix].nil? && other[:suffix] == team[:suffix]
      end <= 1

      logger.error "team number #{team[:number]} has the same suffix "\
        'as another team from the same school'
    end

    def unambiguous_cities_per_school?(team, logger)
      return true unless @schools.keys.find do |other|
        team[:city].nil? && !other[1].nil? &&
        team[:school] == other[0] &&
        team[:state] == other[2]
      end

      logger.error "city for team number #{team[:number]} is ambiguous, "\
        'value is required for unambiguity'
    end

    def correct_number_of_exempt_placings?(team, logger)
      count = @placings[team[:number]].count { |p| p[:exempt] }
      return true if count == @exempt

      logger.error "'team: #{team[:number]}' has incorrect number of "\
        "exempt placings (#{count} insteand of #{@exempt})"
    end
  end
end
