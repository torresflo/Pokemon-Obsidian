module GamePlay
  # Module defining the IO of the move teaching scene so user know what to expect
  module MoveTeachingMixin
    # Tell if the move was learnt or not
    # @return [Boolean]
    attr_accessor :learnt
  end
end

GamePlay.move_teaching_mixin = GamePlay::MoveTeachingMixin
