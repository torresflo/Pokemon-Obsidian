module Battle
  module Effects
    class LuckyChant < PositionTiedEffectBase
      # Create a new Lucky Chant effect
      # @param logic [Battle::Logic]
      # @param bank [Integer] bank where the effect acts
      def initialize(logic, bank)
        super(logic, bank, 0)
        @counter = 5
      end

      # Get the effect name
      # @return [Symbol]
      def name
        return :lucky_chant
      end
    end
  end
end
