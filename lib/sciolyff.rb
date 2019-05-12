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
      @rep = rep
      @tournament = rep[:Tournament]
      @events = index_array(rep[:Events], [:name])
      @teams = index_array(rep[:Teams], [:number])
      @placings = index_array(rep[:Placings], %i[event team]).merge \
                  index_array(rep[:Placings], %i[team event]) if rep[:Placings]
      @scores = index_array(rep[:Scores], %i[event team]).merge \
                index_array(rep[:Scores], %i[team event]) if rep[:Scores]
      @penalties = index_array(rep[:Penalties], [:team]) if rep[:Penalties]
    end

    def event_points(team_number, event_name)
      event_points_from_placings(team_number, event_name) if @placings
      event_points_from_scores(team_number, event_name)
    end

    def team_points(team_number)
    end

    def rank_teams
    end

    private

    def index_array(arr, index_keys)
      return arr.first if index_keys.empty?

      indexed_hash = arr.group_by { |x| x[index_keys.first] }

      indexed_hash.transform_values do |a|
        index_array(a, index_keys.drop(1))
      end
    end

    def event_points_from_placings(team_number, event_name)
      event_placings = @placings[event_name]
      placing = event_placings[team_number]

      return @teams.count + 2 if placing[:disqualified]
      return @teams.count + 1 unless placing[:participated] || placing[:place]
      return @teams.count + 0 unless placing[:place]

      # Points is place minus number of exhibition teams with a better place
      placing[:place] - event_placings.count do |p|
        p = p.last
        p[:place] &&
          p[:place] < placing[:place] &&
          @teams[p[:team]][:exhibition]
      end
    end

    def event_points_from_scores(team_number, event_name)
    end
  end
end
