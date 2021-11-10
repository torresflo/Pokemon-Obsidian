module Battle
  module Effects
    module Mechanics
      # Give functions to manage a move that force the next one. Must be used in a EffectBase child class.
      module ForceNextMove
        # Get the move the Pokemon has to use
        # @return [Battle::Move]
        attr_reader :move
        # Get the targets of the move
        # @return [Array<PFM::PokemonBattler>]
        attr_reader :targets

        # Tell if the effect forces the next move
        # @return [Boolean]
        def force_next_move?
          return true
        end

        # Make the Attack action that is forced by this effect
        # @return [Actions::Attack]
        def make_action
          raise "Failed to make effect for #{self.class}" unless @pokemon && @logic

          target = targets.first
          return action_class.new(@logic.scene, move, @pokemon, target.bank, target.position)
        end

        # Get the class of the action
        # @return [Class<Actions::Attack>]
        def action_class
          Actions::Attack
        end

        private

        # Create a new Forced next move effect
        # @param move [Battle::Move]
        # @param counter [Integer] number of turn the move is forced to be used
        # @param targets [Array<PFM::PokemonBattler>]
        def init_force_next_move(move, targets, counter = 2)
          @move = move
          @targets = targets
          self.counter = counter
        end
      end
    end
  end
end
