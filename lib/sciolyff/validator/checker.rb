# frozen_string_literal: true

module SciolyFF
  # An empty base class to ensure consistent inheritance. All instance methods
  # in children classes should take the arguments rep and logger.
  class Validator::Checker
    def initialize(rep); end

    # Wraps initialize for child classes
    module SafeInitialize
      def initialize(rep, logger)
        super rep
      rescue StandardError => e
        logger.debug "#{e}\n  #{e.backtrace.first}"
      end
    end

    def self.inherited(subclass)
      subclass.prepend SafeInitialize
    end

    # wraps method calls (always using send in Validator) so that exceptions
    # in the check cause check to pass, as what caused the exception should
    # cause some other check to fail if the SciolyFF is truly invalid
    #
    # this simplifies the checking code greatly, even if it is a bit hacky
    def send(method, *args)
      super
    rescue StandardError => e
      args[1].debug "#{e}\n  #{e.backtrace.first}" # args[1] is the logger
    end
  end
end
