module Battle
  module Effects
    class Item
      class PowerHerb < Item
        # Function called after a battler proceed its two turn move's first turn
        # @param user [PFM::PokemonBattler]
        # @param targets [Array<PFM::PokemonBattler>, nil]
        # @param skill [Battle::Move, nil]
        # @return [Boolean, nil] weither or not the two turns move is executed in one turn
        def on_two_turn_shortcut(user, targets, skill)
          return if exceptions.include?(skill.db_symbol)

          # TODO, play animation
          @logic.scene.display_message_and_wait(parse_text_with_pokemon(19, 1028, user, PFM::Text::ITEM2[1] => user.item_name))
          @logic.item_change_handler.change_item(:none, true, user)
          return true
        end

        EXCEPTIONS = %i[sky_drop]
        def exceptions
          EXCEPTIONS
        end
      end
      register(:power_herb, PowerHerb)
    end
  end
end
