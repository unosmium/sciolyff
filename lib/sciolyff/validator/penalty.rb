# frozen_string_literal: true

require 'sciolyff/validator/checker'
require 'sciolyff/validator/sections'

module SciolyFF
  # One event in the Events section of a SciolyFF file
  class Validator::Penalty < Validator::Checker
    include Validator::Sections

    REQUIRED = {
      team: Integer,
      points: Integer
    }.freeze

    OPTIONAL = {
    }.freeze
  end
end
