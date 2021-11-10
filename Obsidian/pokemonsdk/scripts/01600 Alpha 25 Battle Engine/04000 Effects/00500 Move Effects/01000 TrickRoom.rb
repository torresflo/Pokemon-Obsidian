module Battle
  module Effects
    # TrickRoom Effect
    class TrickRoom < EffectBase
      # Create a new effect
      # @param logic [Battle::Logic] logic used to get all the handler in order to allow the effect to work
      def initialize(logic)
        super
        self.counter = 5
      end

      # Get the name of the effect
      # @return [Symbol]
      def name
        return :trick_room
      end

      # Show the message when the effect gets deleted
      def on_delete
        @logic.scene.display_message_and_wait(parse_text(18, 122))
      end
    end
  end
end
