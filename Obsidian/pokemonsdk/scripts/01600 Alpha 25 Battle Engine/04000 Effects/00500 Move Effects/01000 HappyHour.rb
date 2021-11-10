module Battle
  module Effects
    # HappyHour Effect
    class HappyHour < EffectBase
      # Create a new effect
      # @param logic [Battle::Logic] logic used to get all the handler in order to allow the effect to work
      def initialize(logic)
        super
      end

      # Get the name of the effect
      # @return [Symbol]
      def name
        return :happy_hour
      end
    end
  end
end
