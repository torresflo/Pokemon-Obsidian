module Battle
  class Move
    class ReflectType < Move
      private

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        target = actual_targets.first
        return if target.typeless?
        return if always_failing_target.include?(target.db_symbol)

        user.type1 = (target.type1 == 0 && target.type2 == 0) ? 1 : target.type1
        user.type2 = target.type2
        user.type3 = target.type3
        logic.scene.display_message_and_wait(message(user, target))
      end

      # Get the db_symbol of the Pokemon on which the move always fails
      # @return [Array<Symbol>]
      def always_failing_target
        return %i[arceus silvally]
      end

      # Get the right message to display
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler]
      # @return [String]
      def message(user, target)
        return parse_text_with_2pokemon(19, 1095, user, target)
      end
    end
    Move.register(:s_reflect_type, ReflectType)
  end
end
