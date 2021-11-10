module Battle
  class Move
    # Class managing Rest
    # @see https://bulbapedia.bulbagarden.net/wiki/Rest_(move)
    class Rest < Move
      # Function that tests if the targets blocks the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] expected target
      # @note Thing that prevents the move from being used should be defined by :move_prevention_target Hook.
      # @return [Boolean] if the target evade the move (and is not selected)
      def move_blocked_by_target?(user, target)
        return true if super

        # Pseudo logic.status_change_handler.status_appliable? (because of the cure effect)
        # Don't forget to update this function when adding a new move

        # Fail if has Insomnia, Vital Spirit, Sweet Veil
        if target.has_ability?(:insomnia) || target.has_ability?(:vital_spirit) || target.has_ability?(:sweet_veil)
          scene.visual.show_ability(target)
          scene.display_message_and_wait(parse_text_with_pokemon(19, 451, target))
          return true
        # Fail if hp are max
        elsif target.hp == target.max_hp
          scene.display_message_and_wait(parse_text_with_pokemon(19, 451, target))
          return true
        # Fail if affected by Heal Block
        elsif target.effects.has?(:heal_block)
          txt = parse_text_with_pokemon(19, 893, user, '[VAR PKNICK(0000)]' => user.given_name, '[VAR MOVE(0001)]' => name)
          scene.display_message_and_wait(txt)
          return true
        # Fail if affected by Misty Terrain
        elsif @logic.field_terrain_effect.misty? && target.affected_by_terrain?
          scene.display_message_and_wait(parse_text_with_pokemon(19, 845, target))
          return true
        # Fail if affected by Electric Terrain
        elsif @logic.field_terrain_effect.electric? && target.affected_by_terrain?
          scene.display_message_and_wait(parse_text_with_pokemon(19, 1207, target))
          return true
        # Fail if affected by Uproar
        elsif uproar?
          scene.display_message_and_wait(parse_text_with_pokemon(19, 709, target))
          return true
        end
        return false
      end

      # If a pokemon is using Uproar
      # @return [Boolean]
      def uproar?
        fu = @logic.all_alive_battlers.find { |pkm| pkm.effects.has?(:uproar) }
        return !fu.nil?
      end

      # Function that deals the status condition to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_status(user, actual_targets)
        actual_targets.each do |target|
          scene.visual.show_info_bar(target)
          target.status_sleep(true, 3) # Two turns + the current turn
          scene.display_message_and_wait(parse_text_with_pokemon(19, 306, target))
          hp = target.max_hp
          logic.damage_handler.heal(target, hp, test_heal_block: false) do
            scene.display_message_and_wait(parse_text_with_pokemon(19, 638, target))
          end
          target.item_effect.execute_berry_effect if target.item_effect.instance_of?(Effects::Item::StatusBerry::Chesto)
        end
      end
    end
    Move.register(:s_rest, Rest)
  end
end
