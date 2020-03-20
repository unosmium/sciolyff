# frozen_string_literal: true

require 'sciolyff/validator/checker'
require 'sciolyff/validator/sections'

module SciolyFF
  # Checks for one penalty in the Penalties section of a SciolyFF file
  class Validator::Penalties < Validator::Checker
    include Validator::Sections

    REQUIRED = {
      team: Integer,
      points: Integer
    }.freeze

    OPTIONAL = {
    }.freeze
  end
end
