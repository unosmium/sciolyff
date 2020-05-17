# frozen_string_literal: true

module SciolyFF
  # Subdivision logic, to be used in the Interpreter class
  module Interpreter::Subdivisions
    private

    def subdivision_rep(sub)
      # make a deep copy of rep
      rep = Marshal.load(Marshal.dump(@rep))

      remove_teams_not_in_subdivision(rep, sub)
      fix_subdivision_tournament_fields(rep, sub)
      limit_maximum_place(rep)
      fix_placings_for_existing_teams(rep) unless raws?
      rep
    end

    def remove_teams_not_in_subdivision(rep, sub)
      rep[:Teams].select! { |t| t.delete(:subdivision) == sub }

      team_numbers = rep[:Teams].map { |t| t[:number] }
      rep[:Placings].select! { |p| team_numbers.include? p[:team] }
    end

    def fix_subdivision_tournament_fields(rep, sub)
      tournament_rep = rep[:Tournament]
      sub_rep = rep[:Subdivisions].find { |s| s[:name] == sub }

      replace_tournament_fields(tournament_rep, sub_rep)

      tournament_rep.delete(:bids)
      tournament_rep.delete(:'bids per school')
      rep.delete(:Subdivisions)
    end

    def replace_tournament_fields(tournament_rep, sub_rep)
      [:medals, :trophies, :'maximum place'].each do |key|
        tournament_rep[key] = sub_rep[key] if sub_rep.key?(key)
      end
    end

    def limit_maximum_place(rep)
      max_place = rep[:Tournament][:'maximum place']
      team_count = rep[:Teams].count { |t| !t[:exhibition] }

      rep[:Tournament].delete(:'maximum place') if
        !max_place.nil? && max_place > team_count
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
