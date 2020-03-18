# frozen_string_literal: true

require 'sciolyff/validator/checker'
require 'sciolyff/validator/sections'

module SciolyFF
  # Top-level sections of a SciolyFF file
  class Validator::TopLevel < Validator::Checker
    include Validator::Sections

    def initialize
      @required = {
        Tournament: Hash,
        Events: Array,
        Teams: Array,
        Placings: Array
      }
      @optional = {
        Penalties: Array
      }
    end
  end
end
