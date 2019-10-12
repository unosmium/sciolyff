# frozen_string_literal: true

require 'yaml'
require 'date'
require 'sciolyff/top_level'
require 'sciolyff/sections'
require 'sciolyff/tournament'
require 'sciolyff/events'
require 'sciolyff/teams'
require 'sciolyff/placings'
require 'sciolyff/scores'
require 'sciolyff/penalties'
require 'sciolyff/interpreter'

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
    rep = YAML.safe_load(file, permitted_classes: [Date], symbolize_names: true)
  rescue StandardError => e
    puts 'Error: could not read file as YAML.'
    warn e.message
  else
    puts FILE_VALIDATION_MESSAGE
    validate(rep, opts: opts)
  end

  FILE_VALIDATION_MESSAGE = <<~STRING
    Validating file with Minitest...

    Overkill? Probably.
    Doesn't give line numbers from original file? Yeah.

  STRING
end
