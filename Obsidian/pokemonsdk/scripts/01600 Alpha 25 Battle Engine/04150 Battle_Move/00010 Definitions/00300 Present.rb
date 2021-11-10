module Battle
  class Move
    class Present < BasicWithSuccessfulEffect
      # Get the real base power of the move (taking in account all parameter)
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def real_base_power(user, target)
        return @real_base_power if @real_base_power
        # Do your calculation here without removing the previous line (safety mesure to prevent bugs in deal_damages)
        rng = logic.generic_rng.rand(1..100)
        log_data("Rng gave you: #{rng}")
        if rng <= 40
          return 40
        elsif rng <= 70
          return 80
        elsif rng <= 80
          return 120
        else
          return 0
        end
      end

      def power
        return @real_base_power || 0
      end

      # Function that deals the damage to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_damage(user, actual_targets)
        @real_base_power = real_base_power(user, target)
        if @real_base_power > 0
          super
          return false
        end
        return true
      ensure
        @real_base_power = nil
      end

      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          hp = (target.max_hp / 4).floor
          if target.effects.has?(:heal_block)
            log_data('Heal blocked')
            scene.display_message_and_wait(parse_text_with_pokemon(19, 890, target))
          elsif target.hp == target.max_hp
            log_data('Target has MAX HP')
            scene.display_message_and_wait(parse_text_with_pokemon(19, 896, target))
          else
            log_data('Healing time')
            logic.damage_handler.heal(target, hp, test_heal_block: false)
          end
        end
      end
    end
    Move.register(:s_present, Present)
  end
end
