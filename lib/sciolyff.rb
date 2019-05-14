# frozen_string_literal: true

require 'yaml'
require 'sciolyff/top_level'
require 'sciolyff/sections'
require 'sciolyff/tournament'
require 'sciolyff/events'
require 'sciolyff/teams'
require 'sciolyff/placings'
require 'sciolyff/scores'
require 'sciolyff/penalties'

# API methods for the Scioly File Format
#
module SciolyFF
  class << self
    attr_accessor :rep
  end

  # Assumes rep is the output of YAML.load
  def self.validate(rep, opts: {})
    SciolyFF.rep = rep

    mt_args = []
    mt_args << '--verbose' if opts[:verbose]

    Minitest.run mt_args
  end

  def self.validate_file(path, opts: {})
    file = File.read(path)
    rep = YAML.safe_load(file, permitted_classes: [Date], symbolize_names: true)
  rescue StandardError => e
    puts 'Error: could not read file as YAML.'
    warn e.message
  else
    puts FILE_VALIDATION_MESSAGE
    validate(rep, opts: opts)
  end

  FILE_VALIDATION_MESSAGE = <<~STRING
    Validating file with Minitest...

    Overkill? Probably.
    Doesn't give line numbers from original file? Yeah.

  STRING

  # Wrapper class around a SciolyFF Ruby object representation with utility
  # methods to help in displaying results
  class Helper
    def initialize(rep)
      @rep = rep
      @tournament = rep[:Tournament]
      @events = index_array(rep[:Events], [:name])
      @teams = index_array(rep[:Teams], [:number])
      @placings_by_event = index_array(rep[:Placings], %i[event team])
      @placings_by_team = index_array(rep[:Placings], %i[team event])
      @penalties = index_array(rep[:Penalties], [:team]) if rep[:Penalties]
    end

    def event_points(team_number, event_name)
      placing = @placings_by_event[event_name][team_number]

      if placing[:disqualified] then @teams.count + 2
      elsif placing[:participated] == false then @teams.count + 1
      elsif placing[:place].nil? then @teams.count
      else calculate_event_points(placing)
      end
    end

    def team_points(team_number)
      @placings_by_team[team_number]
        .values
        .reject { |p| @events[p[:event]][:trial] }
        .reject { |p| @events[p[:event]][:trialed] }
        .sum { |p| event_points(team_number, p[:event]) } \
      + team_points_from_penalties(team_number)
    end

    def sort_teams_by_rank
      @teams
        .values
        .sort do |a, b|
        cmp = team_points(a[:number]) - team_points(b[:number])
        cmp.zero? ? break_tie(a[:number], b[:number]) : cmp
      end
    end

    def medal_counts(team_number)
      (1..(@teams.count + 2)).map do |m|
        @events
          .values
          .reject { |e| e[:trial] || e[:trialed] }
          .count { |e| event_points(team_number, e[:name]) == m }
      end
    end

    private

    def index_array(arr, index_keys)
      return arr.first if index_keys.empty?

      indexed_hash = arr.group_by { |x| x[index_keys.first] }

      indexed_hash.transform_values do |a|
        index_array(a, index_keys.drop(1))
      end
    end

    def calculate_event_points(placing)
      # Points is place minus number of exhibition teams with a better place
      placing[:place] -
        @placings_by_event[placing[:event]]
        .values
        .select { |p| @teams[p[:team]][:exhibition] && p[:place] }
        .count { |p| p[:place] < placing[:place] }
    end

    def team_points_from_penalties(team_number)
      if @penalties.nil? || @penalties[team_number].nil? then 0
      else @penalties[team_number][:points]
      end
    end

    def break_tie(team_number_a, team_number_b)
      medal_counts(team_number_a)
        .zip(medal_counts(team_number_b))
        .map { |count| count.last - count.first }
        .find(proc { team_number_a <=> team_number_b }, &:nonzero?)
    end
  end
end
