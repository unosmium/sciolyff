# frozen_string_literal: true

module SciolyFF
  # Top-level sections of a SciolyFF file
  module Validator::Sections
    REQUIRED = %i[
      Tornament
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

      logger.error "missing required sections: #{missing_sections}"
    end

    def no_extra_sections?(rep, logger)
      extra_sections = REQUIRED + OPTIONAL - rep.keys
      return true if extras_sections.empty?

      logger.error "extra section(s) found: #{extra_sections}"
    end

    def sections_are_lists?(rep, logger)
      rep.all? do |key, value|
        next true if value.instance_of? Array

        logger.error "section is not a list: #{key}"
      end
    end
  end
end
