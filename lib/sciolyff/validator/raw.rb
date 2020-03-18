# frozen_string_literal: true

require 'sciolyff/validator/checker'
require 'sciolyff/validator/sections'

module SciolyFF
  # One raw of a placing in the Placings section of a SciolyFF file
  class Validator::Raw < Validator::Checker
    include Validator::Sections

    def initialize
      @required = {
        score: Float
      }
      @optional = {
        'tiebreaker rank': Integer
      }
    end
  end
end
