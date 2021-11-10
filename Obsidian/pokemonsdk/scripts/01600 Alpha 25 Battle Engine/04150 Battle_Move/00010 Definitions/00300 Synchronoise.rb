module Battle
  class Move
    # class managing moves that damages all adjacent enemies that share one type with the user
    class Synchronoise < Basic
      private

      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        if user.typeless? || targets.none? { |target| share_types?(user, target) }
          show_usage_failure(user)
          return false
        end
        return true if super
      end

      # Function that deals the damage to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_damage(user, actual_targets)
        actual_targets.each do |target|
          next unless share_types?(user, target)

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

      # Tell if the user share on type with the target
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Boolean]
      def share_types?(user, target)
        return target.type?(user.type1) || target.type?(user.type2) || (target.type?(user.type3) && user.type3 != 0)
      end
    end
    Move.register(:s_synchronoise, Synchronoise)
  end
end
