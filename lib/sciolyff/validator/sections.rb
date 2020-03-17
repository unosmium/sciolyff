# frozen_string_literal: true

module SciolyFF
  # Top-level sections of a SciolyFF file
  module Validator::Sections
    REQUIRED = %i[
      Tournament
      Events
      Teams
      Placings
    ].freeze

    OPTIONAL = %i[
      Penalties
    ].freeze

    def all_required_sections?(rep, logger)
      missing_sections = REQUIRED - rep.keys
      return true if missing_sections.empty?

      logger.error "missing required sections: #{missing_sections.join ', '}"
    end

    def no_extra_sections?(rep, logger)
      extra_sections = rep.keys - (REQUIRED + OPTIONAL)
      return true if extra_sections.empty?

      logger.error "extra section(s) found: #{extra_sections.join ', '}"
    end

    def sections_are_lists?(rep, logger)
      rep.all? do |key, value|
        next true if value.instance_of? Array

        logger.error "section is not a list: #{key}"
      end
    end
  end
end
