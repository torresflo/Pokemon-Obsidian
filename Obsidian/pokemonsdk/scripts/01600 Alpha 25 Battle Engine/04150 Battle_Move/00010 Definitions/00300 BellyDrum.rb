module Battle
  class Move
    class BellyDrum < Move
      private

      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        hp = (user.max_hp / 2).floor
        can_change_atk = logic.stat_change_handler.stat_increasable?(:atk, user)
        if user.hp < hp || !can_change_atk
          show_usage_failure(user)
          return false
        end
        return true
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        hp = (user.max_hp / 2).floor
        scene.visual.show_hp_animations([user], [-hp])
        scene.display_message_and_wait(parse_text_with_pokemon(19, 1255, user))
        logic.stat_change_handler.stat_change_with_process(:atk, 12, user)
      end
    end
    Move.register(:s_bellydrum, BellyDrum)
  end
end
