# frozen_string_literal: true

require 'sciolyff/validator/checker'
require 'sciolyff/validator/sections'

module SciolyFF
  # One event in the Events section of a SciolyFF file
  class Validator::Penalty < Validator::Checker
    REQUIRED = {
      team: Integer,
      points: Integer
    }.freeze

    OPTIONAL = {
    }.freeze

    include Validator::Sections
  end
end
