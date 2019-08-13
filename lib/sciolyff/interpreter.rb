# frozen_string_literal: true

module SciolyFF
  class Interpreter
    require 'sciolyff/interpreter/tournament'
    require 'sciolyff/interpreter/event'
    require 'sciolyff/interpreter/team'
    require 'sciolyff/interpreter/placing'
    require 'sciolyff/interpreter/penalty'

    attr_reader :tournament, :events, :teams, :placings, :penalties

    def initialize(rep)
      @tournament = Tournament.new(rep)

      create_models(rep)
      link_models(self)
    end

    private

    def create_models(rep)
      @events    = map_array_to_models rep[:Events],    Event,   rep
      @teams     = map_array_to_models rep[:Teams],     Team,    rep
      @placings  = map_array_to_models rep[:Placings],  Placing, rep
      @penalties = map_array_to_models rep[:Penalties], Penalty, rep
    end

    def link_models(interpreter)
      # models have to linked in reverse order because reasons
      @penalties.each { |m| m.link_to_other_models(interpreter) }
      @placings .each { |m| m.link_to_other_models(interpreter) }
      @teams    .each { |m| m.link_to_other_models(interpreter) }
      @events   .each { |m| m.link_to_other_models(interpreter) }
    end

    def map_array_to_models(arr, object_class, rep)
      return [] if arr.nil?

      arr.map.with_index { |_, index| object_class.new(rep, index) }
    end
  end
end
