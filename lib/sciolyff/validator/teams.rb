# frozen_string_literal: true

require 'sciolyff/validator/checker'
require 'sciolyff/validator/sections'

module SciolyFF
  # All teams in the Teams section of a SciolyFF file
  class Validator::Teams < Validator::Checker
    def unique_numbers?(teams, logger)
      numbers = teams.map { |team| team[:number] }
      teams.map do |team|
        next true if numbers.count(team[:number]) == 1

        logger.error "duplicate team number: #{team[:number]}"
      end.all?
    end

    def unique_suffixes_per_school?(teams, logger)
      schools = teams.group_by { |t| [t[:school], t[:state], t[:city]] }
      schools.map do |school, school_teams|
        next true if school_teams.map { |t| t[:suffix] }.compact.uniq!.nil?

        logger.error "#{school} has the same suffix for multiple teams"
      end.all?
    end
  end
end
