module Battle
  class Move
    # Class managing moves that deal a status or flinch
    class Transform < BasicWithSuccessfulEffect
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super

        unless logic.transform_handler.can_transform?(user)
          show_usage_failure(user)
          return false
        end

        return true
      end

      # Function that tests if the targets blocks the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] expected target
      # @note Thing that prevents the move from being used should be defined by :move_prevention_target Hook.
      # @return [Boolean] if the target evade the move (and is not selected)
      def move_blocked_by_target?(user, target)
        return true if super

        return !logic.transform_handler.can_copy?(target)
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        target = actual_targets
        user.transform = target.sample(random: logic.generic_rng)
        scene.visual.show_switch_form_animation(user)
        scene.visual.wait_for_animation
        user.effects.add(Effects::Transform.new(logic, user))
      end
    end

    Move.register(:s_transform, Transform)
  end
end
