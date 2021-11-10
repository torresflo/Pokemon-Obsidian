module Battle
  class Move
    # Assist move
    class Assist < Move
      CANNOT_BE_SELECTED_MOVES = %i[
        assist baneful_bunker beak_blast belch bestow bounce celebrate chatter circle_throw copycat counter covet destiny_bound detect dig
        dive dragon_tail endure feint fly focus_punch follow_me helping_hand hold_hands king_s_shield mat_block me_first metronome mimic
        mirror_coat mirror_move nature_power phantom_force protect rage_powder roar shadow_force shell_trap sketch sky_drop sleep_talk snatch
        spiky_shield spotlight struggle switcheroo thief transform trick whirlwind
      ]

      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super

        if usable_moves(user).empty?
          show_usage_failure(user)
          return false
        end

        return true
      end

      private

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        skill = usable_moves(user).sample(random: @logic.generic_rng)
        move = Battle::Move[skill.be_method].new(skill.id, 1, 1, @scene)

        def move.move_usable_by_user(user, targets)
          return true
        end
        use_another_move(move, user)
      end

      # Function that list all the moves the user can pick
      # @param user [PFM::PokemonBattler]
      # @return [Array<Battle::Move>]
      def usable_moves(user)
        team = @logic.trainer_battlers.reject { |pkm| pkm == user }
        skills = team.flat_map(&:moveset).uniq(&:db_symbol)
        skills.reject! { |move| CANNOT_BE_SELECTED_MOVES.include?(move.db_symbol) }
        return skills
      end
    end
    Move.register(:s_assist, Assist)
  end
end
