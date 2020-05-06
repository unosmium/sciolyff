# frozen_string_literal: true

require 'sciolyff/interpreter/model'

module SciolyFF
  # Models a Science Olympiad tournament
  class Interpreter::Tournament < Interpreter::Model
    def initialize(rep)
      @rep = rep[:Tournament]
    end

    def link_to_other_models(interpreter)
      @events = interpreter.events
      @teams = interpreter.teams
      @placings = interpreter.placings
      @penalties = interpreter.penalties
      @subdivisions = interpreter.subdivisions
    end

    attr_reader :events, :teams, :placings, :penalties, :subdivisions

    undef tournament

    def name
      @rep[:name]
    end

    def short_name
      @rep[:'short name']
    end

    def location
      @rep[:location]
    end

    def level
      @rep[:level]
    end

    def state
      @rep[:state]
    end

    def division
      @rep[:division]
    end

    def year
      @rep[:year]
    end

    def date
      @date ||= if @rep[:date].instance_of?(Date)
                  @rep[:date]
                else
                  Date.parse(@rep[:date])
                end
    end

    def medals
      @rep[:medals] || [calc_medals, maximum_place].min
    end

    def trophies
      @rep[:trophies] || [calc_trophies, nonexhibition_teams_count].min
    end

    def worst_placings_dropped?
      worst_placings_dropped.positive?
    end

    def worst_placings_dropped
      @rep[:'worst placings dropped'] || 0
    end

    def exempt_placings?
      exempt_placings.positive?
    end

    def exempt_placings
      @rep[:'exempt placings'] || 0
    end

    def custom_maximum_place?
      maximum_place != nonexhibition_teams_count
    end

    def maximum_place
      return @rep[:'maximum place'] if @rep[:'maximum place']

      nonexhibition_teams_count
    end

    def per_event_n?
      @rep[:'per-event n']
    end

    def n_offset
      @rep[:'n offset'] || 0
    end

    def ties?
      @ties ||= placings.map(&:tie?).any?
    end

    def ties_outside_of_maximum_places?
      @ties_outside_of_maximum_places ||= placings.map do |p|
        p.tie? && !p.points_limited_by_maximum_place?
      end.any?
    end

    def subdivisions?
      !@subdivisions.empty?
    end

    def nonexhibition_teams_count
      @nonexhibition_teams_count ||= @teams.count { |t| !t.exhibition? }
    end

    private

    def calc_medals
      [(nonexhibition_teams_count / 10r).ceil, 3].max
    end

    def calc_trophies
      [(nonexhibition_teams_count / 6r).ceil, 3].max
    end
  end
end
