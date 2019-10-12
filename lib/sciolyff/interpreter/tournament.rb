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
      @rep.key? :'worst placings dropped'
    end

    def worst_placings_dropped
      worst_placings_dropped? ? @rep[:'worst placings dropped'] : 0

    end

    def max_points_per_event(trial: false)
      return @teams.size + 2 if trial

      @teams.count { |t| !t.exhibition? } + 2
    end
  end
end
