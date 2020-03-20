# frozen_string_literal: true

require 'sciolyff/validator/checker'
require 'sciolyff/validator/sections'

module SciolyFF
  # Top-level sections of a SciolyFF file
  class Validator::TopLevel < Validator::Checker
    include Validator::Sections

    REQUIRED = {
      Tournament: Hash,
      Events: Array,
      Teams: Array,
      Placings: Array
    }.freeze

    OPTIONAL = {
      Penalties: Array
    }.freeze
  end
end
