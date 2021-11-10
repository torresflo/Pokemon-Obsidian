module Battle
  module Effects
    class EchoedVoice < EffectBase
      def initialize(logic)
        super
        @successive_turns = 0
        @has_increased = false
      end

      # Increase the value of the successive turn
      def increase
        @has_increased = true
      end

      # Number of consecutive turns where the effect has been updated
      # @return [Integer]
      def successive_turns
        return @successive_turns
      end

      # Function called at the end of a turn
      # @param logic [Battle::Logic] logic of the battle
      # @param scene [Battle::Scene] battle scene
      # @param battlers [Array<PFM::PokemonBattler>] all alive battlers
      def on_end_turn_event(logic, scene, battlers)
        return kill unless @has_increased

        @successive_turns += 1
        @has_increased = false
      end

      def name
        :echoed_voice
      end
    end
  end
end
