module Battle
  class Move
    class Bestow < Move
      private

      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super
        return false unless logic.item_change_handler.can_give_item?(user, targets.first)

        return true
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        target = actual_targets.first
        item = user.battle_item_db_symbol
        logic.item_change_handler.change_item(item, true, target, user, self)
        logic.item_change_handler.change_item(:none, true, user, user, self)
        logic.terrain_effects.add(Battle::Effects::Bestow.new(logic, user, target, item))
        logic.scene.display_message_and_wait(give_text(user, target, user.item_name))
      end

      # Get the text displayed when the user gives its item to the target
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [Array<PFM::PokemonBattler>]
      # @param item [String] the name of the item
      # @return [String] the text to display
      def give_text(user, target, item)
        return parse_text_with_2pokemon(19, 1117, user, target, ::PFM::Text::ITEM2[2] => item)
      end
    end
    Move.register(:s_bestow, Bestow)
  end
end
