module Battle
  module Effects
    class Ability
      class Pickpocket < Ability
        # Function called after damages were applied (post_damage, when target is still alive)
        # @param handler [Battle::Logic::DamageHandler]
        # @param hp [Integer] number of hp (damage) dealt
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def on_post_damage(handler, hp, target, launcher, skill)
          return if target != @target || launcher == target || target.item_db_symbol != :__undef__
          return unless skill&.direct? && launcher && launcher.hp > 0
          return unless handler.logic.item_change_handler.can_lose_item?(launcher, target)

          handler.scene.visual.show_ability(target)
          handler.logic.item_change_handler.change_item(launcher.item_db_symbol, !$game_temp.trainer_battle, target)
          text = parse_text_with_pokemon(19, 460, launcher, PFM::Text::PKNICK[0] => launcher.given_name, PFM::Text::ITEM2[1] => launcher.item_name)
          handler.scene.display_message_and_wait(text)
          target.item_stolen = false
          if launcher.from_party?
            launcher.item_stolen = true
          else
            handler.logic.item_change_handler.change_item(:none, true, launcher)
          end
        end
      end
      register(:pickpocket, Pickpocket)

      class Magician < Ability
        # Function called after damages were applied (post_damage, when target is still alive)
        # @param handler [Battle::Logic::DamageHandler]
        # @param hp [Integer] number of hp (damage) dealt
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def on_post_damage(handler, hp, target, launcher, skill)
          return if launcher != @target || launcher == target || launcher.item_db_symbol != :__undef__
          return unless skill&.direct? && launcher && launcher.hp > 0
          return unless handler.logic.item_change_handler.can_lose_item?(target, launcher)

          handler.scene.visual.show_ability(launcher)
          handler.logic.item_change_handler.change_item(target.item_db_symbol, !$game_temp.trainer_battle, launcher)
          text = parse_text_with_pokemon(19, 1063, launcher, PFM::Text::PKNICK[0] => launcher.given_name,
                                                             PFM::Text::ITEM2[1] => target.item_name,
                                                             PFM::Text::PKNICK[1] => target.given_name)
          handler.scene.display_message_and_wait(text)
          launcher.item_stolen = false
          if target.from_party?
            target.item_stolen = true
          else
            handler.logic.item_change_handler.change_item(:none, true, target)
          end
        end
      end
      register(:magician, Magician)
    end
  end
end
