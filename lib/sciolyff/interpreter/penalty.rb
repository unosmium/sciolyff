# frozen_string_literal: true

require 'sciolyff/interpreter/model'

module SciolyFF
  class Interpreter::Penalty < Interpreter::Model
    def link_to_other_models(interpreter)
      super
      @team = interpreter.teams.find { |t| t.number == @rep[:team] }
    end

    attr_reader :team

    def points
      @rep[:points]
    end
  end
end
