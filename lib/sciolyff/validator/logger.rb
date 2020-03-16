# frozen_string_literal: true

module SciolyFF
  module Validator
    ERROR = 0
    WARN  = 1
    INFO  = 2
    DEBUG = 3

    # Prints extra information produced by validation process
    class Logger
      def initialize(loglevel)
        @loglevel = loglevel
      end

      def error(msg)
        return if loglevel < ERROR

        puts "ERROR (invalid SciolyFF): #{msg}"
      end

      def warn(msg)
        return if loglevel < WARN

        puts "WARNING (still valid SciolyFF): #{msg}"
      end

      def info(msg)
        return if loglevel < INFO

        puts "INFO: #{msg}"
      end

      def debug(msg)
        return if loglevel < DEBUG

        puts "DEBUG: #{msg}"
      end
    end
  end
end
