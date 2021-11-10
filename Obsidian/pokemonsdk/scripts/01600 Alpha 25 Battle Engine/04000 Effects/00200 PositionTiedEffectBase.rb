module Battle
  module Effects
    # Class that describe an effect that is tied to a position (& a bank)
    class PositionTiedEffectBase < EffectBase
      # Get the bank of the effect
      # @return [Integer]
      attr_reader :bank
      # Get the position of the effect
      # @return [Integer]
      attr_reader :position

      # Create a new position tied effect
      # @param logic [Battle::Logic] logic used to get all the handler in order to allow the effect to work
      # @param bank [Integer] bank where the effect is tied
      # @param position [Integer] position where the effect is tied
      def initialize(logic, bank, position)
        super(logic)
        @bank = bank
        @position = position
      end

      private

      # Function that helps to get the pokemon related to the effect
      def affected_pokemon
        @logic.battler(@bank, @position)
      end
    end
  end
end
