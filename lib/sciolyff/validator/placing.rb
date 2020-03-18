# frozen_string_literal: true

require 'sciolyff/validator/checker'
require 'sciolyff/validator/sections'

module SciolyFF
  # One placing in the Placings section of a SciolyFF file
  class Validator::Placing < Validator::Checker
    include Validator::Sections

    def initialize
      @required = {
        event: String,
        team: Integer
      }
      @optional = {
        place: Integer,
        participated: [true, false],
        disqualified: [true, false],
        exempt: [true, false],
        tie: [true, false],
        unknown: [true, false],
        raw: Hash
      }
    end
  end
end
