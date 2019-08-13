require 'sciolyff/interpreter/model'

module SciolyFF
  class Interpreter::Team < Interpreter::Model
    def link_to_other_models(interpreter)
      @placings  = interpreter.placings .select { |p| p.team == self }
      @penalties = interpreter.penalties.select { |p| p.team == self }
    end

    attr_accessor :placings, :penalties

    def school
      @rep[:school]
    end

    def school_abbreviation
      @rep[:'school abbreviation']
    end

    def suffix
      @rep[:suffix]
    end

    def subdivision
      @rep[:subdivision]
    end

    def exhibition?
      @rep[:exhibition] == true
    end

    def number
      @rep[:number]
    end

    def city
      @rep[:city]
    end

    def state
      @rep[:state]
    end
  end
end
