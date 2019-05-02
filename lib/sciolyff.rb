# frozen_string_literal: true

require 'yaml'
require 'sciolyff/top_level_test'
require 'sciolyff/tournament_test'

# API methods for the Scioly File Format
#
module SciolyFF
  class << self
    attr_accessor :rep
  end

  def self.validate(rep)
    SciolyFF.rep = rep
    Minitest.run
  end

  def self.validate_file(path)
    file = File.read(path)
    rep = YAML.load(file)
  rescue StandardError => exception
    puts 'Error: could not read file as YAML.'
    warn exception.message
  else
    puts <<~STRING
      Validating file with Minitest...

      Overkill? Probably.
      Doesn't give line numbers from original file? Yeah.

    STRING
    validate(rep)
  end
end
