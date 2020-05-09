# frozen_string_literal: true

module SciolyFF
  # Bid assignment logic, to be included in the Interpreter::Tournament class
  module Interpreter::Bids
    def top_teams_per_school
      # explicitly relies on uniq traversing in order
      @top_teams_per_school ||= @teams.uniq { |t| [t.school, t.city, t.state] }
    end

    def teams_eligible_for_bids
      return top_teams_per_school if bids_per_school == 1

      # doesn't rely on group_by preserving order
      @teams_eligible_for_bids ||=
        @teams
        .group_by { |t| [t.school, t.city, t.state] }
        .each_value { |teams| teams.sort_by!(&:rank) }
        .map { |_, teams| teams.take(bids_per_school) }
        .flatten
        .sort_by(&:rank)
    end
  end
end
