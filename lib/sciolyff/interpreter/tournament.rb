require 'sciolyff/interpreter/model'

module SciolyFF
  class Interpreter::Tournament < Interpreter::Model
    def initialize(rep)
      @rep = rep[:Tournament]
    end

    def name
      @rep[:name]
    end

    def short_name
      @rep[:short_name]
    end

    def location
      @rep[:location]
    end

    def level
      @rep[:level]
    end

    def state
      @rep[:state]
    end

    def division
      @rep[:division]
    end

    def year
      @rep[:year]
    end

    def date
      @rep[:date]
    end
  end
end
