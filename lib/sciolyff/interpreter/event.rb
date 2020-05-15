# frozen_string_literal: true

require 'sciolyff/interpreter/model'

module SciolyFF
  # Models an instance of a Science Olympiad event at a specific tournament
  class Interpreter::Event < Interpreter::Model
    def link_to_other_models(interpreter)
      super
      @placings = interpreter.placings.select { |p| p.event == self }
      @placings_by_team =
        @placings.group_by(&:team).transform_values!(&:first)
      @raws = @placings.select(&:raw?).map(&:raw).sort
    end

    attr_reader :placings, :raws

    def name
      @rep[:name]
    end

    def trial?
      @rep[:trial] || false
    end

    def trialed?
      @rep[:trialed] || false
    end

    def high_score_wins?
      !low_score_wins?
    end

    def low_score_wins?
      @rep[:scoring] == 'low'
    end

    def placing_for(team)
      @placings_by_team[team]
    end

    def maximum_place
      @maximum_place ||=
        if trial?
          placings.size
        elsif tournament.per_event_n?
          [per_event_maximum_place, tournament.maximum_place].min
        else
          tournament.maximum_place
        end
    end

    private

    def per_event_maximum_place
      return competing_teams_count if tournament.per_event_n == 'participation'

      placings.map(&:place).compact.max + 1
    end

    def competing_teams_count
      return placings.count(&:participated?) if trial?

      placings.count do |p|
        p.participated? && !(p.team.exhibition? || p.exempt?)
      end
    end
  end
end
