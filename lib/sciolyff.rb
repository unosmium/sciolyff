# frozen_string_literal: true

require 'yaml'
require_relative 'sciolyff_tester.rb'

# API methods for the Scioly File Format
#
module SciolyFF
  def self.validate(rep)
    $rep = rep
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
