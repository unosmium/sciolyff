# frozen_string_literal: true

module SciolyFF
  # Grants ability to convert a SciolyFF file into stand-alone HTML and other
  # formats (YAML, JSON)
  module Interpreter::HTML
    require 'erb'
    require 'sciolyff/interpreter/html/helpers'
    require 'json'

    def to_html(hide_raw: false, color: '#000000')
      helpers = Interpreter::HTML::Helpers.new
      ERB.new(
        helpers.template,
        trim_mode: '<>'
      ).result(helpers.get_binding(self, hide_raw, color))
         .gsub(/^\s*$/, '')   # remove empty lines
         .gsub(/\s+$/, '')    # remove trailing whitespace
    end

    def to_yaml(hide_raw: false)
      rep = hide_raw ? hidden_raw_rep : @rep
      stringify_keys(rep).to_yaml
    end

    def to_json(hide_raw: false, pretty: false)
      rep = hide_raw ? hidden_raw_rep : @rep
      return JSON.pretty_generate(rep) if pretty

      rep.to_json
    end

    private

    def hidden_raw_rep
      @hidden_raw_rep || begin
        @hidden_raw_rep = Marshal.load(Marshal.dump(@rep))
        @hidden_raw_rep[:Placings].each { |p| hide_and_replace_raw(p) }
        @hidden_raw_rep
      end
    end

    def hide_and_replace_raw(placing_rep)
      placing = placings.find do |p|
        p.event.name == placing_rep[:event] &&
          p.team.number == placing_rep[:team]
      end
      placing_rep.delete :raw
      placing_rep[:tie] = true if placing.tie?
      placing_rep[:place] = placing.place if placing.place
    end

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
