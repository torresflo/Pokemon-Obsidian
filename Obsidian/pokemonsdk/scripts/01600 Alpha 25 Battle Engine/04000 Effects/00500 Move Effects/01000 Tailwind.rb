module Battle
  module Effects
    class Tailwind < PositionTiedEffectBase
      # Create a new Tailwind effect
      # @param logic [Battle::Logic]
      # @param bank [Integer] bank where the effect acts
      def initialize(logic, bank)
        super(logic, bank, 0)
        @counter = 4
      end

      # Function called when the effect has been deleted from the effects handler
      def on_delete
        @logic.scene.display_message_and_wait(parse_text(18, @bank == 0 ? 148 : 149))
      end

      # Give the speed modifier over given to the Pokemon with this effect
      # @return [Float, Integer] multiplier
      def spd_modifier
        return 2
      end

      # Get the effect name
      # @return [Symbol]
      def name
        return :tailwind
      end
    end
  end
end
