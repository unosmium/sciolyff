# frozen_string_literal: true

module SciolyFF
  # Generic tests for (sub-)sections and types. Including classes must
  # initialize two hashes @required and @optional (see other files in this dir
  # for examples)
  module Validator::Sections
    def all_required_sections?(rep, logger)
      missing = @required.keys - rep.keys
      return true if missing.empty?

      logger.error "missing required sections: #{missing.join ', '}"
    end

    def no_extra_sections?(rep, logger)
      extra = rep.keys - (@required.keys + @optional.keys)
      return true if extra.empty?

      logger.error "extra section(s) found: #{extra.join ', '}"
    end

    def sections_are_correct_type?(rep, logger)
      correct_types = @required.merge @optional
      rep.all? do |key, value|
        if correct_types[key].instance_of? Array
          correct_types[key].include? value
        elsif value.instance_of? correct_types[key]
          true
        else
          logger.error "#{key}: #{value} is not #{correct_types[key]}"
        end
      end
    end
  end
end
