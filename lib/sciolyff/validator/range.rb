# frozen_string_literal: true

module SciolyFF
  # Helper method to check for value in range and report error if not
  module Validator::Range
    private

    def within_range?(rep, key, logger, min, max)
      value = rep[key]
      return true if value.nil? || value.between?(min, max)

      logger.error "'#{key}: #{value}' is not within range [#{min}, #{max}]"
    end
  end
end
