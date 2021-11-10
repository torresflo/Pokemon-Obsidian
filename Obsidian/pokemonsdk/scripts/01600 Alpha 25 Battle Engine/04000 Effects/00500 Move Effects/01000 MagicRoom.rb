module Battle
  module Effects
    class MagicRoom < EffectBase
      # Create a new effect
      # @param logic [Battle::Logic] logic used to get all the handler in order to allow the effect to work
      def initialize(logic, duration)
        super(logic)
        self.counter = duration
        @logic.scene.display_message_and_wait(parse_text(18, 186))
      end

      # Function called when the effect has been deleted from the effects handler
      def on_delete
        @logic.scene.display_message_and_wait(parse_text(18, 187))
      end

      def name
        :magic_room
      end

      # Function called when a held item wants to perform its action
      # @return [Boolean] weither or not the item can't proceed (true will stop the item)
      def on_held_item_use_prevention
        true
      end
    end
  end
end
