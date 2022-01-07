module GamePlay
  # Module defining the IO of the move reminder scene so user know what to expect
  module MoveReminderMixin
    # Tell if a move was learnt or not
    # @return [Boolean]
    attr_accessor :return_data

    # Tell if the move reminder reminded a move or not
    # @return [Boolean]
    def reminded_move?
      @return_data
    end
  end
end

GamePlay.move_reminder_mixin = GamePlay::MoveReminderMixin
