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
      @log = String.new
    end

    def error(msg)
      return false if @loglevel < ERROR

      @log << "ERROR (invalid SciolyFF): #{msg}\n"
      false # convenient for using logging the error as return value
    end

    def warn(msg)
      return true if @loglevel < WARN

      @log << "WARNING (still valid SciolyFF): #{msg}\n"
    end

    def info(msg)
      return true if @loglevel < INFO

      @log << "INFO: #{msg}\n"
    end

    def debug(msg)
      return true if @loglevel < DEBUG

      @log << "DEBUG (possible intentional exception): #{msg}\n"
    end
  end
end
