module Battle
  module Actions
    # Class describing the activation message of item granting priority
    class HighPriorityItem < Base
      # Create a new high priority item action
      # @param scene [Battle::Scene]
      # @param holder [PFM::PokemonBattler]
      def initialize(scene, holder)
        super(scene)
        @holder = holder
      end

      # Compare this action with another
      # @param other [Base] other action
      # @return [Integer]
      def <=>(other)
        return -1 if other.is_a?(Flee)

        return 1
      end

      # Execute the action
      def execute
        item_name = @holder.item_name
        @holder.send(:consume_berry, @holder) if @holder.item_effect.is_a?(Effects::Item::Berry)
        @scene.display_message_and_wait(parse_text_with_pokemon(19, 1031, @holder, PFM::Text::ITEM2[1] => item_name))
      end
    end
  end
end
