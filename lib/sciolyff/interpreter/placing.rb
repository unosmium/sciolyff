# frozen_string_literal: true

require 'sciolyff/interpreter/model'

module SciolyFF
  # Models the result of a team participating (or not) in an event
  class Interpreter::Placing < Interpreter::Model
    def link_to_other_models(interpreter)
      super
      @event = interpreter.events.find { |e| e.name   == @rep[:event] }
      @team  = interpreter.teams .find { |t| t.number == @rep[:team]  }

      link_to_placing_in_subdivision_interpreter(interpreter)
    end

    attr_reader :event, :team, :subdivision

    def participated?
      @rep[:participated] == true || @rep[:participated].nil?
    end

    def disqualified?
      @rep[:disqualified] == true
    end

    def exempt?
      @rep[:exempt] == true
    end

    def unknown?
      @rep[:unknown] == true
    end

    def tie?
      @rep[:tie] == true
    end

    def place
      @rep[:place]
    end

    def did_not_participate?
      !participated?
    end

    def participation_only?
      participated? && !place && !disqualified? && !unknown?
    end

    def dropped_as_part_of_worst_placings?
      team.worst_placings_to_be_dropped.include?(self)
    end

    def points
      @points ||= if !considered_for_team_points? then 0
                  else isolated_points
                  end
    end

    def isolated_points
      max_place = event.maximum_place
      n = max_place + tournament.n_offset

      if    disqualified? then n + 2
      elsif did_not_participate? then n + 1
      elsif participation_only? || unknown? then n
      else  [calculate_points, max_place].min
      end
    end

    def considered_for_team_points?
      initially_considered_for_team_points? &&
        !dropped_as_part_of_worst_placings?
    end

    def initially_considered_for_team_points?
      !(event.trial? || event.trialed? || exempt?)
    end

    def points_affected_by_exhibition?
      considered_for_team_points? && place && !exhibition_placings_behind.zero?
    end

    def points_limited_by_maximum_place?
      tournament.custom_maximum_place? &&
        (unknown? || (place && calculate_points > event.maximum_place))
    end

    private

    def calculate_points
      return place if event.trial?

      place - exhibition_placings_behind
    end

    def exhibition_placings_behind
      @exhibition_placings_behind ||= event.placings.count do |p|
        (p.exempt? || p.team.exhibition?) &&
          p.place &&
          p.place < place
      end
    end

    def link_to_placing_in_subdivision_interpreter(interpreter)
      return @subdivision = nil unless (sub = @team.subdivision)

      @subdivision = interpreter.subdivisions[sub].placings.find do |p|
        p.event.name = @rep[:event] && p.team.number = @rep[:team]
      end
    end
  end
end
