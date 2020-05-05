# frozen_string_literal: true

module SciolyFF
  # Logic for checking against canonical lists of events and schools
  module Validator::Canonical
    BASE = 'https://raw.githubusercontent.com/unosmium/canonical-names/master/'

    private

    def canonical?(rep, file, logger)
      return true if @canonical_warned || !logger.options[:canonical_checks]

      @canonical_list ||= CSV.parse(URI.open(BASE + file))
      # don't try to make this more efficient, harder than it looks because of
      # nil comparisons
      @canonical_list.include?(rep)
    rescue StandardError => e
      logger.warn "could not read canonical names file: #{BASE + file}"
      logger.debug "#{e}\n  #{e.backtrace.first}"
      @canonical_warned = true
    end
  end
end
