module Battle
  class Move
    # Class describing a basic move (damage + potential status + potential stat)
    class Basic < Move
      # Function that deals the damage to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_damage(user, actual_targets)
        # Status move does not deal damages
        return true if status?
        raise 'Badly configured move, it should have positive power' if power < 0

        actual_targets.each do |target|
          hp = damages(user, target)
          @logic.damage_handler.damage_change_with_process(hp, target, user, self) do
            if critical_hit?
              scene.display_message_and_wait(actual_targets.size == 1 ? parse_text(18, 84) : parse_text_with_pokemon(19, 384, target))
            elsif hp > 0
              efficent_message(effectiveness, target)
            end
          end
          recoil(hp, user) if recoil?
        end

        return true
      end

      # Test if the effect is working
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      # @return [Boolean]
      def effect_working?(user, actual_targets)
        if !status? && user.can_be_lowered_or_canceled?(target = actual_targets.find { |t| t.has_ability?(:shield_dust) })
          @scene.visual.show_ability(target) if effect_chance == 100
          return false
        end

        if user.has_ability?(:serene_grace)
          n = 2
        else
          n = 1
        end

        return bchance?((effect_chance * n) / 100.0) && super # super ensure that the magic_bounce & magic_coat effect works
      end
    end

    # Class describing a basic move (damage + status + stat = garanteed)
    class BasicWithSuccessfulEffect < Basic
      # Test if the effect is working
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      # @return [Boolean]
      def effect_working?(user, actual_targets)
        exec_hooks(Move, :effect_working, binding)
        return true
      end
    end

    Move.register(:s_basic, Basic)
  end
end
