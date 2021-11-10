module Battle
  module Effects
    class Item
      class ChoiceScarf < Item
        # Give the speed modifier over given to the Pokemon with this effect
        # @return [Float, Integer] multiplier
        def spd_modifier
          return 1.5
        end

        # Function called when we try to check if the user cannot use a move
        # @param user [PFM::PokemonBattler]
        # @param move [Battle::Move]
        # @return [Proc, nil]
        def on_move_disabled_check(user, move)
          return unless user == @target && user.move_history.any?
          return if user.move_history.last.db_symbol == move.db_symbol
          return if user.move_history.last.turn < user.last_sent_turn

          return proc {
            move.scene.visual.show_item(user)
            move.scene.display_message_and_wait(parse_text_with_pokemon(19, 911, user, PFM::Text::MOVE[1] => move.name))
          }
        end
      end
      register(:choice_scarf, ChoiceScarf)
    end
  end
end
