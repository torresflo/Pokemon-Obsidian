module Battle
  module Effects
    class HelpingHand < PokemonTiedEffectBase
      include Mechanics::WithMarkedTargets

      # Create a new HelpingHand effect
      # @param logic [Battle::Logic]
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler]
      # @param duration [Integer]
      def initialize(logic, user, target, duration)
        super(logic, user)
        initialize_with_marked_targets(user, [target]) { |t| create_mark_effect(t, duration) }
        self.counter = duration
      end

      # Function giving the name of the effect
      # @return [Symbol]
      def name
        :helping_hand
      end

      private

      # @param target [PFM::PokemonBattler]
      # @param duration [Integer]
      # @return [EffectBase]
      def create_mark_effect(target, duration)
        Mark.new(@logic, target, self, duration)
      end

      # Class marking the target of the LeechSeed so we cannot apply the effect twice
      class Mark < PokemonTiedEffectBase
        include Mechanics::Mark

        # Create a new mark
        # @param logic [Battle::Logic]
        # @param pokemon [PFM::PokemonBattler]
        # @param origin [LeechSeed] origin of the mark
        def initialize(logic, pokemon, origin, duration)
          super(logic, pokemon)
          initialize_mark(origin)
          self.counter = duration
        end

        # Give the move base power mutiplier
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move] move
        # @return [Float, Integer] multiplier
        def base_power_multiplier(user, target, move)
          log_data("base_power_multiplier x#{user == @pokemon ? 1.5 : super} # helping hand")
          return user == @pokemon ? 1.5 : super
        end

        # Name of the effect
        # @return [Symbol]
        def name
          :helping_hand_mark
        end
      end
    end
  end
end
