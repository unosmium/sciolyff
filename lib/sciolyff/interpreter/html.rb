# frozen_string_literal: true

module SciolyFF
  # Grants ability to convert a SciolyFF file into stand-alone HTML
  module Interpreter::HTML
    require 'erb'
    require 'sciolyff/interpreter/html/helpers'

    def html
      helpers = Interpreter::HTML::Helpers.new
      ERB.new(helpers.template).result(helpers.get_binding(self))
    end
  end
end
