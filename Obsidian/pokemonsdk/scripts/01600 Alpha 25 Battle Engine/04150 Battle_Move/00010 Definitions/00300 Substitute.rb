module Battle
  class Move
    # Move that put the mon into a substitue
    class Substitute < BasicWithSuccessfulEffect
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super

        if user.hp_rate < 0.25
          show_usage_failure(user)
          return false
        end

        return true
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        if user.effects.has?(:substitute)
          scene.display_message_and_wait(parse_text_with_pokemon(19, 788, user))
        else
          user.effects.add(Effects::Substitute.new(logic, user))
          scene.visual.show_switch_form_animation(user)
          scene.display_message_and_wait(parse_text_with_pokemon(19, 785, user))
        end
      end
    end

    Move.register(:s_substitute, Substitute)
  end
end
