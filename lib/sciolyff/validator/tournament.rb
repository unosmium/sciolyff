# frozen_string_literal: true

require 'sciolyff/validator/checker'
require 'sciolyff/validator/sections'

module SciolyFF
  # Tournament section of a SciolyFF file
  class Validator::Tournament < Validator::Checker
    include Validator::Sections

    def initialize
      @required = {
        location: String,
        level: %w[Invitational Regionals States Nationals],
        division: %w[A B C],
        year: Integer,
        date: Date
      }
      @optional = {
        name: String,
        state: String,
        'short name': String,
        'worst placings dropped': Integer,
        'exempt placings dropped': Integer,
        'maximum place': Integer,
        'per-event n': [true, false],
        'n offset': Integer
      }
    end
  end
end
