module Battle
  class Move
    # Class managing the Pluck move
    class Pluck < Basic
      private

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        return if user.dead?

        actual_targets.each do |target|
          next unless @logic.item_change_handler.can_lose_item?(target, user) && target.hold_berry?(target.battle_item_db_symbol)

          @scene.display_message_and_wait(parse_text_with_pokemon(19, 776, user, PFM::Text::ITEM2[1] => target.item_name))
          if target.item_effect.is_a?(Effects::Item::Berry)
            # @type [Effects::Item::Berry]
            user_effect = Effects::Item.new(logic, user, target.item_effect.db_symbol)
            user_effect.execute_berry_effect(force_heal: true)
          end
          @logic.item_change_handler.change_item(:none, true, target, user, self)
        end
      end
    end
    Move.register(:s_pluck, Pluck)
  end
end
