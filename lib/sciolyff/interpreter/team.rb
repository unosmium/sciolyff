require 'sciolyff/interpreter/model'

module SciolyFF
  class Interpreter::Team < Interpreter::Model
    def link_to_other_models(interpreter)
      super
      @placings  = interpreter.placings .select { |p| p.team == self }
      @penalties = interpreter.penalties.select { |p| p.team == self }
      @placings_by_event = @placings.group_by(&:event)

      @placings.freeze
      @penalties.freeze
    end

    attr_reader :placings, :penalties

    def school
      @rep[:school]
    end

    def school_abbreviation
      @rep[:'school abbreviation']
    end

    def suffix
      @rep[:suffix]
    end

    def subdivision
      @rep[:subdivision]
    end

    def exhibition?
      @rep[:exhibition] == true
    end

    def number
      @rep[:number]
    end

    def city
      @rep[:city]
    end

    def state
      @rep[:state]
    end

    def placing_for(event)
      @placings_by_event[event]
    end

    def rank
      @tournament.teams.find_index(self) + 1
    end

    def points
      return @cache[:points] if @cache[:points]

      counted_placings = placings.select(&:considered_for_team_points?)

      if @tournament.worst_placings_dropped?
        counted_placings
          .sort!(&:points)
          .reverse!
          .drop!(@tournament.worst_placings_dropped)
      end

      @cache[:points] =
        counted_placings.sum(&:points) + penalties.sum(&:points)
    end

    def trial_event_points
      placings.select { |p| p.event.trial? }.sum(&:points)
    end

    def medal_counts
      (1..@tournament.max_points_per_event).map do |medal_points|
        placings.select(&:considered_for_team_points?)
                .count { |p| p.points == medal_points }
      end
    end

    def trial_event_medal_counts
      (1..@tournament.max_points_per_event(trial: true)).map do |medal_points|
        placings.select { |p| p.event.trial? }
                .count { |p| p.points == medal_points }
      end
    end
  end
end
