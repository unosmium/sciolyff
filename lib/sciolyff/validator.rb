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
    require 'sciolyff/validator/event'
    require 'sciolyff/validator/events'
    require 'sciolyff/validator/team'
    require 'sciolyff/validator/teams'
    require 'sciolyff/validator/placing'
    require 'sciolyff/validator/placings'
    require 'sciolyff/validator/penalty'
    require 'sciolyff/validator/raw'

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

    def valid_rep?(rep, logger)
      unless rep.instance_of? Hash
        logger.error 'improper file structure'
        return false
      end

      check(TopLevel, rep, logger) &&
        level_one_checks(rep, logger) &&
        level_two_checks(rep, logger) &&
        level_three_checks(rep, logger) &&
        level_four_checks(rep, logger)
    end

    def level_one_checks(rep, logger)
      [
        check(Tournament, rep[:Tournament], logger),
        rep[:Events].all? { |e| check(Event, e, logger) },
        rep[:Teams].all? { |t| check(Team, t, logger) }
      ].all?
    end

    def level_two_checks(rep, logger)
      [
        check(Events, rep[:Events], logger),
        check(Teams, rep[:Teams], logger),
        rep[:Placings].all? { |p| check(Placing, p, logger) },
        rep[:Penalties]&.all? { |p| check(Penalty, p, logger) }
      ].compact.all?
    end

    def level_three_checks(rep, logger)
      [
        check(Placings, rep[:Placings], logger)
      ].all?
    end

    def level_four_checks(rep, logger)
      [
        rep[:Placings]
          .map { |p| p[:raw] }.compact.all? { |r| check(Raw, r, logger) }
      ].compact.all?
    end

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

    def check(klass, rep, logger)
      anon = klass.new
      checks = klass.instance_methods - Checker.instance_methods
      checks.all? { |im| anon.send im, rep, logger }
    end
  end
end
