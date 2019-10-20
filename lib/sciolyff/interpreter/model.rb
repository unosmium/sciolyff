# frozen_string_literal: true

module SciolyFF
  # Parent class for other nested classes within Interpreter
  class Interpreter::Model
    def initialize(rep, index)
      @rep = rep[pluralize_for_key(self.class)][index]
    end

    def link_to_other_models(interpreter)
      @tournament = interpreter.tournament
    end

    attr_reader :tournament

    # prevents infinite loop due caused by intentional circular references
    def inspect
      to_s.delete_suffix('>') + " @rep=#{@rep}>"
    end

    private

    def pluralize_for_key(klass)
      name = klass.name.split('::').last
      name = name.delete_suffix('y') + 'ie' if name.end_with?('y')
      (name + 's').to_sym
    end
  end
end
