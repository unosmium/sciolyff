# frozen_string_literal: true

module SciolyFF
  # Generic tests for (sub-)sections and types. Including classes must have two
  # hashes REQUIRED and OPTIONAL (see other files in this dir for examples)
  module Validator::Sections
    def rep_is_hash?(rep, logger)
      return true if rep.instance_of? Hash

      logger.error "entry in #{section_name} is not a Hash"
    end

    def all_required_sections?(rep, logger)
      missing = self.class::REQUIRED.keys - rep.keys
      return true if missing.empty?

      logger.error "missing required sections: #{missing.join ', '}"
    end

    def no_extra_sections?(rep, logger)
      extra = rep.keys - (self.class::REQUIRED.keys + self.class::OPTIONAL.keys)
      return true if extra.empty?

      logger.error "extra section(s) found: #{extra.join ', '}"
    end

    def sections_are_correct_type?(rep, logger)
      correct_types = self.class::REQUIRED.merge self.class::OPTIONAL
      rep.all? do |key, value|
        correct = correct_types[key]
        next true if
        (correct.instance_of?(Array) && correct.include?(value)) ||
        (correct.instance_of?(Class) && value.instance_of?(correct)) ||
        correct_date?(correct, value)

        logger.error "#{key}: #{value} is not #{correct}"
      end
    end

    private

    def correct_date?(correct, value)
      correct == Date && Date.parse(value)
    rescue StandardError
      false
    end

    def section_name
      self.class.to_s.split('::').last
    end
  end
end
