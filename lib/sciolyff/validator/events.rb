# frozen_string_literal: true

require 'sciolyff/validator/checker'
require 'sciolyff/validator/sections'

module SciolyFF
  # Checks for one event in the Events section of a SciolyFF file
  class Validator::Events < Validator::Checker
    include Validator::Sections

    REQUIRED = {
      name: String
    }.freeze

    OPTIONAL = {
      trial: [true, false],
      trialed: [true, false],
      scoring: %w[high low]
    }.freeze

    def initialize(rep)
      @events = rep[:Events]
      @names = @events.map { |e| e[:name] }
    end

    def unique_name?(event, logger)
      return true if @names.count(event[:name]) == 1

      logger.error "duplicate event name: #{event[:name]}"
    end
  end
end
