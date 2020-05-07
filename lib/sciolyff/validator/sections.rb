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
        type = correct_types[key]
        next true if correct_type?(type, value)

        logger.error "#{key}: #{value} is not #{type}"
      end
    end

    private

    def correct_type?(type, value)
      type.nil? ||
        (type.instance_of?(Array) && type.include?(value)) ||
        (type.instance_of?(Class) && value.instance_of?(type)) ||
        correct_date?(type, value)
    end

    def correct_date?(type, value)
      type == Date && Date.parse(value)
    rescue StandardError
      false
    end

    def section_name
      self.class.to_s.split('::').last
    end
  end
end
