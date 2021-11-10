module Battle
  class Move
    # Class managing the Thief move
    class Thief < BasicWithSuccessfulEffect
      private

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        return if user.dead?
        return false if user.item_db_symbol != :__undef__

        actual_targets.each do |target|
          next unless @logic.item_change_handler.can_lose_item?(target, user)

          additionnal_variables = {
            PFM::Text::ITEM2[2] => target.item_name,
            PFM::Text::PKNICK[1] => target.given_name
          }
          @scene.display_message_and_wait(parse_text_with_pokemon(19, 1063, user, additionnal_variables))
          @logic.item_change_handler.change_item(target.item_db_symbol, !$game_temp.trainer_battle, user, user, self)
          user.item_stolen = false
          if target.from_party?
            target.item_stolen = true
          else
            @logic.item_change_handler.change_item(:none, true, target, user, self)
          end
        end
      end
    end
    Move.register(:s_thief, Thief)
  end
end
