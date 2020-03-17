# frozen_string_literal: true

module SciolyFF
  # Prints extra information produced by validation process
  class Validator::Logger
    ERROR = 0
    WARN  = 1
    INFO  = 2
    DEBUG = 3

    attr_reader :log

    def initialize(loglevel)
      @loglevel = loglevel
      flush
    end

    def flush
      @log = ''
    end

    def error(msg)
      return if loglevel < ERROR

      @log << "ERROR (invalid SciolyFF): #{msg.capitalize}\n"
    end

    def warn(msg)
      return if loglevel < WARN

      @log << "WARNING (still valid SciolyFF): #{msg.capitalize}\n"
    end

    def info(msg)
      return if loglevel < INFO

      @log << "INFO: #{msg.capitalize}\n"
    end

    def debug(msg)
      return if loglevel < DEBUG

      @log << "DEBUG: #{msg.capitalize}\n"
    end
  end
end
