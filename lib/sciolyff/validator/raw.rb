# frozen_string_literal: true

require 'sciolyff/validator/checker'
require 'sciolyff/validator/sections'

module SciolyFF
  # One raw of a placing in the Placings section of a SciolyFF file
  class Validator::Raw < Validator::Checker
    REQUIRED = {
      score: Float
    }.freeze

    OPTIONAL = {
      'tiebreaker rank': Integer
    }.freeze

    include Validator::Sections
  end
end
