# frozen_string_literal: true

require 'sciolyff/validator/checker'
require 'sciolyff/validator/sections'

module SciolyFF
  # One event in the Events section of a SciolyFF file
  class Validator::Penalty < Validator::Checker
    include Validator::Sections

    def initialize(teams)
      @required = {
        team: teams.map { |t| t[:number] },
        points: Integer
      }
      @optional = {
      }
    end
  end
end
