module Battle
  module Actions
    # Class describing the Flee action
    class Flee < Base
      # Get the pokemon trying to flee
      # @return [PFM::PokemonBattler]
      attr_reader :target
      # Create a new flee action
      # @param scene [Battle::Scene]
      # @param target [PFM::PokemonBattler]
      def initialize(scene, target)
        super(scene)
        @target = target
      end

      # Compare this action with another
      # @param other [Base] other action
      # @return [Integer]
      def <=>(other)
        return 1 if other.is_a?(Attack) && Attack.from(other).move.relative_priority > 0

        return -1
      end

      # Execute the action
      # @param from_scene [Boolean] if the action was triggered during the player choice
      def execute(from_scene = false)
        if from_scene
          execute_from_scene
        elsif @scene.logic.switch_handler.can_switch?(@target)
          @scene.display_message_and_wait(parse_text_with_pokemon(19, 767, @target))
          @scene.logic.battle_result = 1
          @scene.next_update = :battle_end
        end
      end

      private

      # Execute the action if the pokemon is from party
      def execute_from_scene
        result = @scene.logic.flee_handler.attempt(@target.position)
        if result == :success
          @scene.logic.battle_result = 1
          @scene.next_update = :battle_end
        end
      end
    end
  end
end
