module Battle
  class Move
    # Move increase changing all moves to electric for 1 turn
    class IonDeluge < Move
      private

      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super

        if logic.terrain_effects.has?(:ion_deluge)
          show_usage_failure(user)
          return false
        end

        return true
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        logic.terrain_effects.add(Effects::IonDeluge.new(@scene.logic))
        scene.display_message_and_wait(parse_text(18, 257))
      end
    end

    Move.register(:s_ion_deluge, IonDeluge)
  end
end
