# frozen_string_literal: true

require 'sciolyff/validator/checker'
require 'sciolyff/validator/sections'

module SciolyFF
  # One raw of a placing in the Placings section of a SciolyFF file
  class Validator::Raw < Validator::Checker
    include Validator::Sections

    REQUIRED = {
      score: Float
    }.freeze

    OPTIONAL = {
      'tiebreaker rank': Integer
    }.freeze
  end
end
