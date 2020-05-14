# frozen_string_literal: true

require 'sciolyff/interpreter/model'
require 'sciolyff/interpreter/bids'

module SciolyFF
  # Models a Science Olympiad tournament
  class Interpreter::Tournament < Interpreter::Model
    def initialize(rep)
      @rep = rep[:Tournament]
    end

    def link_to_other_models(interpreter)
      @events = interpreter.events
      @teams = interpreter.teams
      @placings = interpreter.placings
      @penalties = interpreter.penalties
      @subdivisions = interpreter.subdivisions
    end

    attr_reader :events, :teams, :placings, :penalties, :subdivisions

    undef tournament

    %i[
      name
      location
      level
      state
      division
      year
    ].each do |sym|
      define_method(sym) { @rep[sym] }
    end

    def short_name
      @rep[:'short name']
    end

    def date
      @date ||= if @rep[:date].instance_of?(Date)
                  @rep[:date]
                else
                  Date.parse(@rep[:date])
                end
    end

    def medals
      @rep[:medals] || [calc_medals, maximum_place].min
    end

    def trophies
      @rep[:trophies] || [calc_trophies, nonexhibition_teams_count].min
    end

    def bids
      @rep[:bids] || 0
    end

    def bids_per_school
      @rep[:'bids per school'] || 1
    end

    def worst_placings_dropped?
      worst_placings_dropped.positive?
    end

    def worst_placings_dropped
      @rep[:'worst placings dropped'] || 0
    end

    def exempt_placings?
      exempt_placings.positive?
    end

    def exempt_placings
      @rep[:'exempt placings'] || 0
    end

    def custom_maximum_place?
      maximum_place != nonexhibition_teams_count
    end

    def maximum_place
      @rep[:'maximum place'] || nonexhibition_teams_count
    end

    def per_event_n
      @rep[:'per-event n']
    end

    def per_event_n?
      @rep.key? :'per-event n'
    end

    def n_offset
      @rep[:'n offset'] || 0
    end

    def ties?
      @ties ||= placings.map(&:tie?).any?
    end

    def ties_outside_of_maximum_places?
      @ties_outside_of_maximum_places ||= placings.any? do |p|
        p.tie? && !p.points_limited_by_maximum_place?
      end
    end

    def subdivisions?
      !@subdivisions.empty?
    end

    def nonexhibition_teams_count
      @nonexhibition_teams_count ||= @teams.count { |t| !t.exhibition? }
    end

    include Interpreter::Bids

    private

    def calc_medals
      [(nonexhibition_teams_count / 10r).ceil, 3].max
    end

    def calc_trophies
      [(nonexhibition_teams_count / 6r).ceil, 3].max
    end
  end
end
