module Battle
  class Move
    # Move increase the gravity
    class Gravity < Move
      private

      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        if super
          effect_klass = Effects::Gravity
          if logic.terrain_effects.each.any? { |effect| effect.class == effect_klass }
            show_usage_failure(user)
            return false
          end
          return true
        end

        return false
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        logic.terrain_effects.add(Effects::Gravity.new(@scene.logic))
        scene.display_message_and_wait(parse_text(18, 123))
      end
    end

    Move.register(:s_gravity, Gravity)
  end
end
