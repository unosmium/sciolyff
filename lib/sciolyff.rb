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
    puts <<~STRING
      Validating file with Minitest...

      Overkill? Probably.
      Doesn't give line numbers from original file? Yeah.

    STRING
    validate(rep, opts: opts)
  end

  class Helper
    def initialize(rep)
      @tournament = rep['Tournament']
      @teams = rep['Teams']
    end

    def event_points(team_number, event_name)
      event_points_from_scores(team_number, event_name) if @rep.key? 'Scores'
      event_points_from_placings(team_number, event_name)
    end

    def team_points(team_number)
    end

    def rank_teams
    end

    private

    def event_points_from_placings(team_number, event_name)
      event_placings = @rep['Placings'].select { |p| p['event'] == event_name }
      placing = event_placings.find { |p| p['team'] == team_number }

      return @rep['Teams'].count + 2 if placing['disqualified']
      return @rep['Teams'].count + 1 unless placing['participated']
      return @rep['Teams'].count + 0 unless placing['place']

      # Points is place minus number of exhibition teams with a better place
      placing['place'] - event_placings.count do |p|
        p['place'] < placing['place'] &&
          @rep['Teams'].find { |t| t['number'] == p['team'] }['exhibition']
      end
    end

    def event_points_from_scores(team_number, event_name)
    end
  end
end
