# frozen_string_literal: true

require 'sciolyff/validator/checker'
require 'sciolyff/validator/sections'

module SciolyFF
  # All events in the Events section of a SciolyFF file
  class Validator::Events < Validator::Checker
    def unique_names?(events, logger)
      names = events.map { |event| event[:name] }
      events.map do |event|
        next true if names.count(event[:name]) == 1

        logger.error "duplicate event name: #{event[:name]}"
      end.all?
    end
  end
end
