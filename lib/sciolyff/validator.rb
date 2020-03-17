# frozen_string_literal: true

require 'psych'
require 'date'

module SciolyFF
  # Checks if SciolyFF YAML files and/or representations (i.e. hashes that can
  # be directly converted to YAML) comply with spec (i.e. safe for interpreting)
  class Validator
    require 'sciolyff/validator/logger'
    require 'sciolyff/validator/checker'
    require 'sciolyff/validator/sections'

    require 'sciolyff/validator/top_level'
    require 'sciolyff/validator/tournament'

    def initialize(loglevel = Logger::WARN)
      @logger = Logger.new loglevel
    end

    def valid?(rep_or_file)
      @logger.flush

      if rep_or_file.instance_of? String
        valid_file?(rep_or_file, @logger)
      else
        valid_rep?(rep_or_file, @logger)
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

    def valid_rep?(rep, logger)
      unless rep.instance_of? Hash
        logger.error 'improper file structure'
        return false
      end

      # intentionally (ab)use short-circuiting (&&) or lack of (&)
      check(TopLevel, rep, logger) &&
        check(Tournament, rep[:Tournament], logger)
    end

    def check(klass, rep, logger)
      anon = klass.new
      checks = klass.instance_methods - Checker.instance_methods
      checks.all? { |im| anon.send im, rep, logger }
    end
  end
end
