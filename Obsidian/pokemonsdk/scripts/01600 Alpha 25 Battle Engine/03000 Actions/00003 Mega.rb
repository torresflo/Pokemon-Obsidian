module Battle
  module Actions
    # Class describing the Mega Evolution action
    class Mega < Base
      # Get the user of this action
      # @return [PFM::PokemonBattler]
      attr_reader :user
      # Create a new mega evolution action
      # @param scene [Battle::Scene]
      # @param user [PFM::PokemonBattler]
      def initialize(scene, user)
        super(scene)
        @user = user
      end

      # Compare this action with another
      # @param other [Base] other action
      # @return [Integer]
      def <=>(other)
        return 1 if other.is_a?(HighPriorityItem)
        return 1 if other.is_a?(Attack) && Attack.from(other).pursuit_enabled
        return 1 if other.is_a?(Item)
        return 1 if other.is_a?(Switch)
        return Mega.from(other).user.spd <=> @user.spd if other.is_a?(Mega)

        return -1
      end

      # Execute the action
      def execute
        @scene.logic.mega_evolve.mark_as_mega_evolved(@user)
        @scene.display_message_and_wait(message)
        @user.mega_evolve
        @scene.visual.show_switch_form_animation(@user)
        # TODO!
      end

      private

      # Get the mega evolve message
      # @return [String]
      def message
        return parse_text_with_pokemon(
          19, 1165, @user,
          PFM::Text::PKNICK[0] => @user.given_name,
          PFM::Text::ITEM2[2] => @user.item_name,
          PFM::Text::TRNAME[1] => @user.trainer_name,
          PFM::Text::ITEM2[3] => @scene.logic.mega_evolve.mega_tool_name(@user)
        )
      end
    end
  end
end
