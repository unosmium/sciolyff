# frozen_string_literal: true

require 'sciolyff/validator/checker'
require 'sciolyff/validator/sections'

module SciolyFF
  # One placing in the Placings section of a SciolyFF file
  class Validator::Placing < Validator::Checker
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

    include Validator::Sections
  end
end
