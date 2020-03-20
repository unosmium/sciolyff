# frozen_string_literal: true

module SciolyFF
  # Generic tests for (sub-)sections and types. Including classes must have two
  # hashes REQUIRED and OPTIONAL (see other files in this dir for examples)
  module Validator::Sections
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
        next true if (correct.instance_of?(Array) && correct.include?(value)) ||
                     (value.instance_of? correct)

        logger.error "#{key}: #{value} is not #{correct}"
      end
    end
  end
end
