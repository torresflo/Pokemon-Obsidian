module GamePlay
  module RSEClockHelpers
    # Module defining the questions asked by the RSEClock
    module Questions
      # @!parse include GamePlay::Base
      # @!parse include Logic

      private

      def ask_confirmation
        @choice_result = nil
        yes ||= text_get(11, 27)
        no ||= text_get(11, 28)
        if display_message(question_string, 1, yes, no) == 0
          @choice_result = :YES
        else
          @choice_result = :NO
        end
      end

      def question_string
        format('Is it %<hour>02d:%<minute>02d?', hour: hour, minute: minute)
      end
    end
  end
end
