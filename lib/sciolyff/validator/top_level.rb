# frozen_string_literal: true

require 'sciolyff/validator/checker'
require 'sciolyff/validator/sections'

module SciolyFF
  # Top-level sections of a SciolyFF file
  class Validator::TopLevel < Validator::Checker
    REQUIRED = {
      Tournament: Hash,
      Events: Array,
      Teams: Array,
      Placings: Array
    }.freeze

    OPTIONAL = {
      Penalties: Array
    }.freeze

    include Validator::Sections
  end
end
