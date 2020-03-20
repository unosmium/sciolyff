# frozen_string_literal: true

require 'sciolyff/validator/checker'
require 'sciolyff/validator/sections'

module SciolyFF
  # One team in the Teams section of a SciolyFF file
  class Validator::Team < Validator::Checker
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
  end
end
