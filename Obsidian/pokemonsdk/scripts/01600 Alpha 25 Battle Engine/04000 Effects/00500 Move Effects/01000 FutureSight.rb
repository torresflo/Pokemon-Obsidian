module Battle
  module Effects
    class FutureSight < PositionTiedEffectBase
      # Create a new position tied effect
      # @param logic [Battle::Logic] logic used to get all the handler in order to allow the effect to work
      # @param bank [Integer] bank where the effect is tied
      # @param position [Integer] position where the effect is tied
      # @param countdown [Integer] amount of turn before the effect proc (including the current one)
      # @param damages [Integer] damages dealt by the move
      def initialize(logic, bank, position, countdown, damages)
        super(logic, bank, position)
        self.counter = countdown
        @damages = damages
      end

      # Function giving the name of the effect
      # @return [Symbol]
      def name
        :future_sight
      end

      # Function called when the effect has been deleted from the effects handler
      def on_delete
        return unless appliable?
        return unless (target = find_target)
        return if target.type_dark?

        @logic.scene.display_message_and_wait(proc_message(target))
        # @todo add animation
        @logic.damage_handler.damage_change_with_process(@damages, target)
      end

      private

      # Find the defintive target
      # @return [PFM::PokemonBattler, nil]
      def find_target
        return affected_pokemon if affected_pokemon.alive?

        proto_move = Battle::Move.new(nil, 1, 1, @logic.scene)
        def proto_move.target
          :user_or_adjacent_ally
        end
        return proto_move.battler_targets(affected_pokemon, @logic).select(&:alive?).first
      end

      # Is the effect triggered?
      # @return [Boolean]
      def triggered?
        return @counter == 1
      end

      # Is the effect appliable?
      # @return [Boolean]
      def appliable?
        return true
      end

      # Message displayed when the effect proc
      # @return [String]
      def proc_message(target)
        parse_text_with_pokemon(19, 1086, target)
      end
    end
  end
end
