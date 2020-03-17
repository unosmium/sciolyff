# frozen_string_literal: true

module SciolyFF
  # Top-level sections of a SciolyFF file
  module Validator::Sections
    REQUIRED = {
      Tournament: Hash,
      Events: Array,
      Teams: Array,
      Placings: Array
    }.freeze

    OPTIONAL = {
      Penalties: Array
    }.freeze

    def all_required_sections?(rep, logger)
      missing_sections = REQUIRED.keys - rep.keys
      return true if missing_sections.empty?

      logger.error "missing required sections: #{missing_sections.join ', '}"
    end

    def no_extra_sections?(rep, logger)
      extra_sections = rep.keys - (REQUIRED.keys + OPTIONAL.keys)
      return true if extra_sections.empty?

      logger.error "extra section(s) found: #{extra_sections.join ', '}"
    end

    def sections_are_correct_type?(rep, logger)
      rep.all? do |key, value|
        correct_type = (REQUIRED.merge OPTIONAL)[key]
        next true if value.instance_of? correct_type

        logger.error "section is not #{correct_type}: #{key}"
      end
    end
  end
end
