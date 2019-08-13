require 'sciolyff/interpreter/model'

module SciolyFF
  class Interpreter::Placing < Interpreter::Model
    def link_to_other_models(interpreter)
      @event = interpreter.events.find { |e| e.name   == @rep[:event] }
      @team  = interpreter.teams .find { |t| t.number == @rep[:team]  }
    end

    attr_accessor :event, :team

    def participated?
      @rep[:participated] == true || @rep[:participated].nil?
    end

    def disqualified?
      @rep[:disqualitied] == true
    end

    def exempt?
      @rep[:exempt] == true
    end

    def unknown?
      @rep[:unknown] == true
    end

    def tie?
      @rep[:tie] == true
    end

    def place
      @rep[:place]
    end
  end
end
