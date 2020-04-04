# frozen_string_literal: true

require 'sciolyff/validator/checker'
require 'sciolyff/validator/sections'

module SciolyFF
  # Checks for one event in the Events section of a SciolyFF file
  class Validator::Events < Validator::Checker
    include Validator::Sections

    REQUIRED = {
      name: String
    }.freeze

    OPTIONAL = {
      trial: [true, false],
      trialed: [true, false],
      scoring: %w[high low]
    }.freeze

    def initialize(rep)
      @events = rep[:Events]
      @names = @events.map { |e| e[:name] }
      @placings = rep[:Placings].group_by { |p| p[:event] }
      @teams = rep[:Teams].count
    end

    def unique_name?(event, logger)
      return true if @names.count(event[:name]) == 1

      logger.error "duplicate event name: #{event[:name]}"
    end

    def placings_for_all_teams?(event, logger)
      count = @placings[event[:name]].count
      return true if count == @teams

      logger.error "'event: #{event[:name]}' has incorrect number of "\
        "placings (#{count} instead of #{@teams})"
    end

    def ties_marked?(event, logger)
      unmarked_ties = placings_by_place(event).select do |_place, placings|
        placings.count { |p| !p[:tie] } > 1
      end
      return true if unmarked_ties.empty?

      logger.error "'event: #{event[:name]}' has unmarked ties at "\
        "place #{unmarked_ties.keys.join ', '}"
    end

    def ties_paired?(event, logger)
      unpaired_ties = placings_by_place(event).select do |_place, placings|
        placings.count { |p| p[:tie] } == 1
      end
      return true if unpaired_ties.empty?

      logger.error "'event: #{event[:name]}' has unpaired ties at "\
        "place #{unpaired_ties.keys.join ', '}"
    end

    def no_gaps_in_places?(event, logger)
      places = places_with_expanded_ties(event)
      return true if places.empty?

      gaps = (places.min..places.max).to_a - places
      return true if gaps.empty?

      logger.error "'event: #{event[:name]}' has gaps in "\
        "place #{gaps.join ', '}"
    end

    def places_start_at_one?(event, logger)
      lowest_place = @placings[event[:name]].map { |p| p[:place] }.compact.min
      return true if lowest_place == 1 || lowest_place.nil?

      logger.error "places for 'event: #{event[:name]}' start at "\
        "#{lowest_place} instead of 1"
    end

    private

    def placings_by_place(event)
      @placings[event[:name]]
        .select { |p| p[:place] }
        .group_by { |p| p[:place] }
    end

    def places_with_expanded_ties(event)
      # e.g. [6, 6, 8] -> [6, 7, 8]
      placings_by_place(event).map do |place, placings|
        (place..(place + (placings.size - 1))).to_a
      end.flatten
    end
  end
end
