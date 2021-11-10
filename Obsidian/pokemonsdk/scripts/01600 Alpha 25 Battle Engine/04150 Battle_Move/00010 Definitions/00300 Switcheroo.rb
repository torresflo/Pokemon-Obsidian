module Battle
  class Move
    class Switcheroo < Move
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super

        unless @logic.item_change_handler.can_lose_item?(user) ||
               targets.any? { |target| @logic.item_change_handler.can_lose_item?(target, user) }
          show_usage_failure(user)
          return false
        end

        return true
      end

      private

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          target_item = target.battle_item_db_symbol
          user_item = user.battle_item_db_symbol

          @logic.item_change_handler.change_item(user_item, false, target, user, self)
          @logic.item_change_handler.change_item(target_item, false, user, user, self)
          @scene.display_message_and_wait(first_message(user))
          @scene.display_message_and_wait(second_message(user)) if target_item != :__undef__
        end
      end

      # First message displayed
      def first_message(pokemon)
        parse_text_with_pokemon(19, 682, pokemon)
      end

      # Second message displayed
      def second_message(pokemon)
        parse_text_with_pokemon(19, 685, pokemon, ::PFM::Text::ITEM2[1] => pokemon.item_name)
      end
    end
    Move.register(:s_trick, Switcheroo)
  end
end
