# frozen_string_literal: true

module SciolyFF
  # Tie-breaking logic for teams, to be used in the Interpreter class
  module Interpreter::Tiebreaks
    private

    def sort_teams_by_points(teams)
      teams.sort do |team_a, team_b|
        cmp = team_a.points <=> team_b.points
        cmp.zero? ? break_tie(team_a, team_b) : cmp
      end
    end

    def break_tie(team_a, team_b)
      team_a.medal_counts
            .zip(team_b.medal_counts)
            .map { |counts| counts.last - counts.first }
            .find(proc { break_second_tie(team_a, team_b) }, &:nonzero?)
    end

    def break_second_tie(team_a, team_b)
      cmp = team_a.trial_event_points <=> team_b.trial_event_points
      cmp.zero? ? break_third_tie(team_a, team_b) : cmp
    end

    def break_third_tie(team_a, team_b)
      team_a.trial_event_medal_counts
            .zip(team_b.trial_event_medal_counts)
            .map { |counts| counts.last - counts.first }
            .find(proc { team_a.number <=> team_b.number }, &:nonzero?)
    end
  end
end
