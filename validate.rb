#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optimist'
require 'yaml'

Optimist.options do
  version 'sciolyff 0.1.0'
  banner <<~STRING
    Checks if a given file is in the Scioly File Format

    Usage:
            ./#{File.basename(__FILE__)} [options] <file>

    where [options] are:
  STRING
end

if ARGV.first.nil? || !File.exist?(ARGV.first)
  puts "Error: file '#{ARGV.first}' not found."
  puts 'Try --help for help.'
  exit
end

begin
  file = File.read(ARGV.first)
  $rep = YAML.load(file)
rescue StandardError => exception
  puts 'Error: could not read file as YAML.'
  warn exception.message
  exit
end

puts 'More than one file given, ignoring all but first.' if ARGV.length > 1

puts <<~STRING
  Validating file with Minitest...

  (overkill? maybe)

STRING

require 'minitest/autorun'

# Tests that also serve as the specification for the sciolyff file format
#
class SciolyFFValidate < Minitest::Test
  def setup
    @rep = $rep
  end
end
