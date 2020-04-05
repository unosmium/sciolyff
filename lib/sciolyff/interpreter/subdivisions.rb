# frozen_string_literal: true

module SciolyFF
  # Subdivision logic, to be used in the Interpreter class
  module Interpreter::Subdivisions
    private

    def subdivision_rep(sub)
      # make a deep copy of rep and remove teams not in the subdivision
      rep = Marshal.load(Marshal.dump(@rep))
      rep[:Teams].select! { |t| t.delete(:subdivision) == sub }

      team_numbers = rep[:Teams].map { |t| t[:number] }
      rep[:Placings].select! { |p| team_numbers.include? p[:team] }

      fix_placings_for_existing_teams(rep)
      rep
    end

    def fix_placings_for_existing_teams(rep)
      rep[:Placings]
        .group_by { |p| p[:event] }
        .each { |_, ep| fix_event_placings(ep) }
    end

    def fix_event_placings(event_placings)
      event_placings
        .select { |p| p[:place] }
        .sort_by { |p| p[:place] }
        .each_with_index { |p, i| p[:temp_place] = i + 1 }
        .each { |p| fix_placing_ties(p, event_placings) }
        .each { |p| p.delete(:temp_place) }
    end

    def fix_placing_ties(placing, event_placings)
      ties = event_placings.select { |o| o[:place] == placing[:place] }
      placing[:place] = ties.map { |t| t[:temp_place] }.max - ties.count + 1
      ties.count > 1 ? placing[:tie] = true : placing.delete(:tie)
    end
  end
end
