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
    attr_reader :rep, :tournament, :events_by_name, :teams_by_number
    attr_reader :placings_by_event, :placings_by_team, :penalties_by_team

    def initialize(rep)
      @rep = rep
      @exhibition_teams_count = rep[:Teams].count { |t| t[:exhibition] }
      @exempt_placings_count = rep[:Placings].count { |p| p[:exempt] }
      @team_points_cache = {}

      @tournament = rep[:Tournament]
      @events_by_name = index_array(rep[:Events], [:name])
      @teams_by_number = index_array(rep[:Teams], [:number])
      @placings_by_event = index_array(rep[:Placings], %i[event team])
      @placings_by_team = index_array(rep[:Placings], %i[team event])
      return unless rep[:Penalties]

      @penalties_by_team = index_array(rep[:Penalties], [:team])
    end

    def nonexhibition_teams
      @teams_by_number.reject { |_, t| t[:exhibition] }
    end

    def event_points(team_number, event_name)
      placing = @placings_by_event[event_name][team_number]
      number_of_teams = number_of_competing_teams(event_name)

      if placing[:disqualified] then number_of_teams + 2
      elsif placing[:participated] == false then number_of_teams + 1
      elsif placing[:unknown] then number_of_teams - 1
      elsif placing[:place].nil? then number_of_teams
      else calculate_event_points(placing)
      end
    end

    def team_points(team_number)
      return @team_points_cache[team_number] if @team_points_cache[team_number]

      @team_points_cache[team_number] = calculate_team_points(team_number)
    end

    def team_points_from_penalties(team_number)
      if @penalties_by_team.nil? || @penalties_by_team[team_number].nil? then 0
      else @penalties_by_team[team_number][:points]
      end
    end

    def sort_teams_by_rank
      @teams_by_number
        .values
        .sort do |a, b|
        next  1 if  a[:exhibition] && !b[:exhibition]
        next -1 if !a[:exhibition] &&  b[:exhibition]

        cmp = team_points(a[:number]) - team_points(b[:number])
        cmp.zero? ? break_tie(a[:number], b[:number]) : cmp
      end
    end

    def medal_counts(team_number)
      (1..(nonexhibition_teams.count + 2)).map do |m|
        @events_by_name
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

    def number_of_competing_teams(event_name)
      return @teams_by_number.count if @events_by_name[event_name][:trial]

      nonexhibition_teams.count
    end

    def calculate_event_points(placing)
      return placing[:place] if simple_placing?(placing)

      # Points is place minus number of exhibition and exempt teams with a
      # better place
      placing[:place] -
        @placings_by_event[placing[:event]]
        .values
        .select { |p| p[:place] && exhibition_or_exempt_placing?(p) }
        .count { |p| p[:place] < placing[:place] }
    end

    def calculate_team_points(team_number)
      @placings_by_team[team_number]
        .values
        .reject { |p| @events_by_name[p[:event]][:trial] }
        .reject { |p| @events_by_name[p[:event]][:trialed] }
        .reject { |p| p[:exempt] }
        .sum { |p| event_points(team_number, p[:event]) } \
      + team_points_from_penalties(team_number)
    end

    def simple_placing?(placing)
      @events_by_name[placing[:event]][:trial] ||
        (@exhibition_teams_count.zero? && @exempt_placings_count.zero?)
    end

    def exhibition_or_exempt_placing?(placing)
      @teams_by_number[placing[:team]][:exhibition] || placing[:exempt]
    end

    def break_tie(team_number_a, team_number_b)
      medal_counts(team_number_a)
        .zip(medal_counts(team_number_b))
        .map { |count| count.last - count.first }
        .find(proc { team_number_a <=> team_number_b }, &:nonzero?)
    end
  end
end
