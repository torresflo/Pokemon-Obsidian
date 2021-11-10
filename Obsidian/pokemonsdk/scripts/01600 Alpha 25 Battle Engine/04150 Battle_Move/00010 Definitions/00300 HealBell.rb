module Battle
  class Move
    # Class describing a heal move
    class HealBell < Move
      # Function that tests if the targets blocks the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] expected target
      # @note Thing that prevents the move from being used should be defined by :move_prevention_target Hook.
      # @return [Boolean] if the target evade the move (and is not selected)
      def move_blocked_by_target?(user, target)
        return true if super

        if target.has_ability?(:soundproof)
          scene.visual.show_ability(target)
          scene.display_message_and_wait(parse_text_with_pokemon(19, 210, target))
          return true
        end
        return false
      end

      # Function that deals the heal to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, targets)
        targets = scene.logic.alive_battlers_without_check(0) unless db_symbol == :refresh
        target_cure = false
        targets.each do |target|
          if !target.dead? && target.status != 0
            scene.logic.status_change_handler.status_change(:cure, target)
            target_cure = true
          end
          scene.display_message_and_wait(parse_text(18, 70)) unless target_cure
        end
      end
    end

    Move.register(:s_heal_bell, HealBell)
  end
end
