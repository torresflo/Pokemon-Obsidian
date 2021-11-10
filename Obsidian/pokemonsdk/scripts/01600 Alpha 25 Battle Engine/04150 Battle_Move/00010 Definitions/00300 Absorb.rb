module Battle
  class Move
    # Class describing a move that drains HP
    class Absorb < Move
      private

      # Test if the target is immune
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler]
      # @return [Boolean]
      def target_immune?(user, target)
        return true if !target.asleep? && be_method == :s_dream_eater

        return super
      end

      # Function that deals the damage to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_damage(user, actual_targets)
        # Status move does not deal damages
        return true if status?
        raise 'Badly configured move, it should have positive power' if power < 0

        actual_targets.each do |target|
          hp = damages(user, target)
          @logic.damage_handler.drain_with_process(hp, target, user, self, hp_overwrite: hp, drain_factor: 2) do
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

      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        if user.effects.has?(:heal_block)
          scene.display_message_and_wait(parse_text_with_pokemon(19, 893, user,
                                                                 '[VAR PKNICK(0000)]' => user.given_name,
                                                                 '[VAR MOVE(0001)]' => name))
          return false
        end
        return true if super
      end

      # Tell that the move is a drain move
      # @return [Boolean]
      def drain?
        return true
      end
    end

    Move.register(:s_absorb, Absorb)
    Move.register(:s_dream_eater, Absorb)
  end
end
