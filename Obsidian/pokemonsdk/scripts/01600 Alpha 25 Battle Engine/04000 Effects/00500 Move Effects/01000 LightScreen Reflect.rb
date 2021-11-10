module Battle
  module Effects
    # Effect describing LightScreen
    class LightScreen < PositionTiedEffectBase
      # Create a new Pokemon tied effect
      # @param logic [Battle::Logic] logic used to get all the handler in order to allow the effect to work
      # @param bank [Integer] bank where the effect is tied
      # @param position [Integer] position where the effect is tied
      # @param turn_count [Integer] number of turn for the confusion (not including current turn)
      def initialize(logic, bank, position, turn_count = 5)
        super(logic, bank, position)
        self.counter = turn_count
      end

      # Give the move mod1 mutiplier (before the +2 in the formula)
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @param move [Battle::Move] move
      # @return [Float, Integer] multiplier
      def mod1_multiplier(user, target, move)
        return 1 if @bank != target.bank || move.critical_hit? || user.has_ability?(:infiltrator)
        return 1 unless move.special?

        return $game_temp.vs_type == 2 ? (2 / 3.0) : 0.5
      end

      # Get the name of the effect
      # @return [Symbol]
      def name
        :light_screen
      end

      def on_delete
        @logic.scene.display_message_and_wait(parse_text(18, message_id + bank.clamp(0, 1)))
      end

      private

      # ID of the message responsive of telling the end of the effect
      # @return [Integer]
      def message_id
        return 136
      end
    end

    # Effect describing Reflect
    class Reflect < LightScreen
      # Give the move mod1 mutiplier (before the +2 in the formula)
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @param move [Battle::Move] move
      # @return [Float, Integer] multiplier
      def mod1_multiplier(user, target, move)
        return 1 if @bank != target.bank || move.critical_hit? || user.has_ability?(:infiltrator)
        return 1 unless move.physical?

        return $game_temp.vs_type == 2 ? (2 / 3.0) : 0.5
      end

      # Get the name of the effect
      # @return [Symbol]
      def name
        :reflect
      end

      private

      # ID of the message responsive of telling the end of the effect
      # @return [Integer]
      def message_id
        return 132
      end
    end
  end
end
