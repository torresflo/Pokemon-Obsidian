module Battle
  module Effects
    # Effect lowering Electric moves
    class MudSport < EffectBase
      # Create a new effect
      # @param logic [Battle::Logic] logic used to get all the handler in order to allow the effect to work
      def initialize(logic)
        super
        self.counter = 5
      end

      # Get the name of the effect
      # @return [Symbol]
      def name
        return :mud_sport
      end

      # Give the move base power mutiplier
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @param move [Battle::Move] move
      # @return [Float, Integer] multiplier
      def base_power_multiplier(user, target, move)
        return move.type_electric? ? 0.5 : 1
      end

      # Show the message when the effect gets deleted
      def on_delete
        @logic.scene.display_message_and_wait(parse_text(18, 121))
      end
    end

    # Effect lowering Fire moves
    class WaterSport < MudSport
      # Get the name of the effect
      # @return [Symbol]
      def name
        return :water_sport
      end

      # Give the move base power mutiplier
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @param move [Battle::Move] move
      # @return [Float, Integer] multiplier
      def base_power_multiplier(user, target, move)
        return move.type_fire? ? 0.5 : 1
      end

      # Show the message when the effect gets deleted
      def on_delete
        @logic.scene.display_message_and_wait(parse_text(18, 119))
      end
    end
  end
end
