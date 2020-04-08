# frozen_string_literal: true

module SciolyFF
  # Grants ability to convert a SciolyFF file into stand-alone HTML and other
  # formats (YAML, JSON)
  module Interpreter::HTML
    require 'erb'
    require 'sciolyff/interpreter/html/helpers'
    require 'json'

    def html
      helpers = Interpreter::HTML::Helpers.new
      ERB.new(
        helpers.template,
        trim_mode: '<>'
      ).result(helpers.get_binding(self))
         .gsub(/^\s*$/, '')   # remove empty lines
         .gsub(/\s+$/, '') +  # remove trailing whitespace
        "<yaml hidden>\n#{yaml}</yaml>"
    end

    def yaml
      stringify_keys(@rep).to_yaml
    end

    def json(pretty: false)
      return JSON.pretty_generate(@rep) if pretty

      @rep.to_json
    end

    private

    def stringify_keys(hash)
      return hash unless hash.instance_of? Hash

      hash.map do |k, v|
        new_k = k.to_s
        new_v = case v
                when Array then v.map { |e| stringify_keys(e) }
                when Hash then stringify_keys(v)
                else v
                end
        [new_k, new_v]
      end.to_h
    end
  end
end
