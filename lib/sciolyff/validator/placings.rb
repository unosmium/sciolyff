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
  end
end
