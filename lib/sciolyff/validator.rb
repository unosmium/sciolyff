# frozen_string_literal: true

require 'psych'
require 'date'

module SciolyFF
  # Checks if SciolyFF YAML files and/or representations (i.e. hashes that can
  # be directly converted to YAML) comply with spec (i.e. safe for interpreting)
  class Validator
    require 'sciolyff/validator/logger'
    require 'sciolyff/validator/sections'
    require 'sciolyff/validator/tournament'
    require 'sciolyff/validator/event'
    require 'sciolyff/validator/team'
    require 'sciolyff/validator/placing'
    require 'sciolyff/validator/placings'
    require 'sciolyff/validator/penalty'

    def initialize(loglevel = Logger::WARN)
      @logger = Logger.new loglevel
    end

    def valid?(rep_or_file)
      @logger.flush

      if rep_or_file.instance_of? String
        valid_file?(rep, @logger)
      else
        valid_rep?(rep, @logger)
      end
    end

    def last_log
      @logger.log
    end

    private

    def valid_file?(path, logger)
      rep = Psych.safe_load(
        File.read(path),
        permitted_classes: [Date],
        symbolize_names: true
      )
    rescue StandardError => e
      logger.error "could not read file as YAML:\n#{e.message}"
    else
      valid_rep?(rep, logger)
    end

    def valid_rep?(rep, _logger)
      unless rep.instance_of? Hash
        logger.error 'improper file structure'
        return false
      end

      true
    end
  end
end
