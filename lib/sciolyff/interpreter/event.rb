require 'sciolyff/interpreter/model'

module SciolyFF
  class Interpreter::Event < Interpreter::Model
    def link_to_other_models(interpreter)
      @placings = interpreter.placings.select { |p| p.event == self }
    end

    attr_accessor :placings

    def name
      @rep[:name]
    end

    def trial?
      @rep[:trial] == true
    end

    def trialed?
      @rep[:trialed] == true
    end

    def high_score_wins?
      @rep[:scoring] == 'high'
    end

    def low_score_wins?
      !high_score_wins?
    end
  end
end
