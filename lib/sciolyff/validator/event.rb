# frozen_string_literal: true

require 'sciolyff/validator/checker'
require 'sciolyff/validator/sections'

module SciolyFF
  # One event in the Events section of a SciolyFF file
  class Validator::Event < Validator::Checker
    include Validator::Sections

    def initialize
      @required = {
        name: String
      }
      @optional = {
        trial: [true, false],
        trialed: [true, false],
        scoring: %w[high low]
      }
    end
  end
end
