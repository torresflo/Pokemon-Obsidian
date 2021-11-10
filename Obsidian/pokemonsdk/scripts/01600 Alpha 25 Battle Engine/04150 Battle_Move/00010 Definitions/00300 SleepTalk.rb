module Battle
  class Move
    # Sleep Talk move
    class SleepTalk < Move
      CANNOT_BE_SELECTED_MOVES = %i[
        assist belch bide bounce copycat dig dive freeze_shock fly focus_punch geomancy ice_burn me_first metronome sleep_talk
        mirror_move mimic phantom_force razor_wind shadow_force sketch skull_bash sky_attack sky_drop solar_beam uproar
      ]

      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        if !user.asleep? || usable_moves.empty?
          show_usage_failure(user)
          return false
        end

        return true if super
      end

      private

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        move = usable_moves.sample(random: @logic.generic_rng).dup
        move.pp = move.ppmax
        def move.move_usable_by_user(user, targets)
          return true
        end
        use_another_move(move, user)
      end

      # Function that list all the moves the user can pick
      # @param user [PFM::PokemonBattler]
      # @return [Array<Battle::Move>]
      def usable_moves(user)
        user.skills_set.reject { |skill| CANNOT_BE_SELECTED_MOVES.include?(skill.db_symbol) }
      end
    end
    Move.register(:s_sleep_talk, SleepTalk)
  end
end
