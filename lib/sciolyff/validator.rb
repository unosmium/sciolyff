# frozen_string_literal: true

require 'psych'
require 'date'

module SciolyFF
  # Checks if SciolyFF YAML files and/or representations (i.e. hashes that can
  # be directly converted to YAML) comply with spec (i.e. safe for interpreting)
  module Validator
    require 'sciolyff/validator/logger'
    require 'sciolyff/validator/tournament'
    require 'sciolyff/validator/event'
    require 'sciolyff/validator/team'
    require 'sciolyff/validator/placing'
    require 'sciolyff/validator/placings'
    require 'sciolyff/validator/penalty'

    def self.valid?(rep_or_file, loglevel = WARN)
      logger = Logger.new loglevel

      if rep_or_file.instance_of? String
        valid_file?(rep, logger)
      else
        valid_rep?(rep, logger)
      end
    end

    private

    def valid_file?(path, logger)
      rep = Psych.safe_load(
        File.read(path),
        permitted_classes: [Date],
        symbolize_names: true
      )
    rescue StandardError => e
      puts 'Error: could not read file as YAML.'
      warn e.message
    else
      valid_rep?(rep, logger)
    end

    def valid_rep?(rep, _logger)
      return false unless rep.instance_of? Hash

      true
    end
  end
end
