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
    end

    attr_reader :events, :teams, :placings, :penalties

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
      @rep[:date]
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
      maximum_place != @teams.count { |t| !t.exhibition? }
    end

    def maximum_place
      return @rep[:'maximum place'] if @rep[:'maximum place']

      @teams.count { |t| !t.exhibition? }
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
  end
end
