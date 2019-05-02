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

  # Assumes rep is the output of YAML.load
  def self.validate(rep, opts: {})
    SciolyFF.rep = rep

    mt_args = []
    mt_args << '--verbose' if opts[:verbose]

    Minitest.run mt_args
  end

  def self.validate_file(path, opts: {})
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
    validate(rep, opts: opts)
  end
end
