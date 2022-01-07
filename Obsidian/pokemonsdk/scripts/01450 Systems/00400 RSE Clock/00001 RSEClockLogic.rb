module GamePlay
  # Module Holding all the modules to include for the RSEClock
  module RSEClockHelpers
    # Module defining the logic of the RSEClock
    module Logic
      # Get the hour that was set on the clock
      # @return [Integer]
      attr_reader :hour
      # Get the minute that was set on the clock
      attr_reader :minute

      # Create a new RSEClock
      # @param hour [Integer] hour to start the clock
      # @param minute [Integer] minute to start the clock
      def initialize(hour = 0, minute = 0)
        super(false)
        @hour = hour
        @minute = minute
        @choice_result = nil
        initialize_state_machine
      end

      private

      # Increase the minutes
      def increase_minutes
        @minute += 1
        update_hour
      end

      # Decrease the minutes
      def decrease_minutes
        @minute -= 1
        update_hour
      end

      # Update the hour based on minutes
      def update_hour
        @hour += @minute / 60
        @hour %= 24
        @minute = @minute % 60
      end
    end
  end
end
