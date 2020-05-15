# frozen_string_literal: true

require 'sciolyff/validator/checker'
require 'sciolyff/validator/sections'

module SciolyFF
  # Checks for one raw of a placing in the Placings section of a SciolyFF file
  class Validator::Raws < Validator::Checker
    include Validator::Sections

    REQUIRED = {
      score: Float
    }.freeze

    OPTIONAL = {
      'tier': Integer,
      'tiebreaker rank': Integer
    }.freeze

    def score_is_not_nan?(raw, logger)
      return true unless raw[:score].nan?

      logger.error "'score: .nan' (not a number) is not permitted"
    end

    def positive_tier?(raw, logger)
      tier = raw[:tier]
      return true if tier.nil? || tier.positive?

      logger.error "'tier: #{tier}' is not positive"
    end

    def positive_tiebreaker_rank?(raw, logger)
      rank = raw[:'tiebreaker rank']
      return true if rank.nil? || rank.positive?

      logger.error "'tiebreaker rank: #{rank}' is not positive"
    end
  end
end
