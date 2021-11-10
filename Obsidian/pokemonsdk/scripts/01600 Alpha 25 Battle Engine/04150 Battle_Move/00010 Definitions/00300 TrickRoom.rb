module Battle
  class Move
    # Move changing speed order of Pokemon
    class TrickRoom < Move
      private

      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        if super
          effect_klass = Effects::TrickRoom
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
        logic.terrain_effects.add(Effects::TrickRoom.new(@scene.logic))
        scene.display_message_and_wait(parse_text_with_pokemon(19, 860, user))
      end
    end

    Move.register(:s_trick_room, TrickRoom)
  end
end
