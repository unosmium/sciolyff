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
      suffix: String,
      city: String,
      disqualified: [true, false],
      exhibition: [true, false]
    }.freeze

    def initialize(rep)
      @teams = rep[:Teams]
      @numbers = @teams.map { |t| t[:number] }
      @schools = @teams.group_by { |t| [t[:school], t[:state], t[:city]] }
    end

    def unique_number?(team, logger)
      return true if @numbers.count(team[:number]) == 1

      logger.error "duplicate team number: #{team[:number]}"
    end

    def unique_suffix_per_school?(team, logger)
      full_school = [team[:school], team[:state], team[:city]]
      return true if @schools[full_school].count(team[:suffix]) <= 1

      logger.error "#{team[:school]} has the same suffix for multiple teams"
    end
  end
end
