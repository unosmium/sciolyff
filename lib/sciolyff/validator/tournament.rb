# frozen_string_literal: true

require 'sciolyff/validator/checker'
require 'sciolyff/validator/sections'

module SciolyFF
  # Checks for Tournament section of a SciolyFF file
  class Validator::Tournament < Validator::Checker
    include Validator::Sections

    REQUIRED = {
      location: String,
      level: %w[Invitational Regionals States Nationals],
      division: %w[A B C],
      year: Integer,
      date: Date
    }.freeze

    OPTIONAL = {
      name: String,
      state: String,
      medals: Integer,
      trophies: Integer,
      'qualifying schools': Integer,
      'short name': String,
      'worst placings dropped': Integer,
      'exempt placings': Integer,
      'maximum place': Integer,
      'per-event n': [true, false],
      'n offset': Integer
    }.freeze

    def initialize(rep)
      @maximum_place = rep[:Teams].count { |t| !t[:exhibition] }
      @schools_count = rep[:Teams].uniq do |t|
        [t[:school], t[:city], t[:state]]
      end.count
    end

    def name_for_not_states_or_nationals?(tournament, logger)
      level = tournament[:level]
      return true if %w[States Nationals].include?(level) || tournament[:name]

      logger.error 'name for Tournament required '\
        "('level: #{level}' is not States or Nationals)"
    end

    def state_for_not_nationals?(tournament, logger)
      return true if tournament[:level] == 'Nationals' || tournament[:state]

      logger.error 'state for Tournament required '\
        "('level: #{tournament[:level]}' is not Nationals)"
    end

    def qualifying_schools_for_regionals_or_states?(tournament, logger)
      level = tournament[:level]
      return true if tournament[:'qualifying schools'].nil? ||
                     %w[Regionals States].include?(level)

      logger.error "'qualifying schools:' does not make sense for "\
        "level: #{level}"
    end

    def short_name_is_relevant?(tournament, logger)
      return true unless tournament[:'short name'] && !tournament[:name]

      logger.error "'short name: #{tournament[:'short name']}' for Tournament "\
        "requires a normal 'name:' as well"
    end

    def short_name_is_short?(tournament, logger)
      return true if tournament[:'short name'].nil? ||
                     tournament[:'short name'].length < tournament[:name].length

      logger.error "'short name: #{tournament[:'short name']}' for Tournament "\
        "is longer than normal 'name: #{tournament[:name]}'"
    end

    def maximum_place_within_range?(tournament, logger)
      return true if tournament[:'maximum place'].nil? ||
                     tournament[:'maximum place'].between?(1, @maximum_place)

      logger.error "custom 'maximum place: #{tournament[:'maximum place']}' "\
        "is not within range [1, #{@maximum_place}]"
    end

    def medals_within_range?(tournament, logger)
      max = [@maximum_place, tournament[:'maximum place']].compact.min
      return true if tournament[:medals].nil? ||
                     tournament[:medals].between?(1, max)

      logger.error "custom 'medals: #{tournament[:medals]}' "\
        "is not within range [1, #{max}]"
    end

    def trophies_within_range?(tournament, logger)
      return true if tournament[:trophies].nil? ||
                     tournament[:trophies].between?(1, @maximum_place)

      logger.error "custom 'trophies: #{tournament[:trophies]}' "\
        "is not within range [1, #{@maximum_place}]"
    end

    def qualifying_schools_within_range?(tournament, logger)
      qual = tournament[:'qualifying schools']
      return true if qual.nil? || qual.between?(1, @schools_count)

      logger.error "'qualifying schools: #{qual}' "\
        "is not within range [1, #{@schools_count}]"
    end
  end
end
