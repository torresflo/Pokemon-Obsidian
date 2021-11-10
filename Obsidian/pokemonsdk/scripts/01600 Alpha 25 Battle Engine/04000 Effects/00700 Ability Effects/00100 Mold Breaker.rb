module Battle
  module Effects
    class Ability
      class MoldBreaker < Ability
        # Function called when we try to use a move as the user (returns :prevent if user fails)
        # @param user [PFM::PokemonBattler]
        # @param targets [Array<PFM::PokemonBattler>]
        # @param move [Battle::Move]
        # @return [:prevent, nil] :prevent if the move cannot continue
        def on_move_prevention_user(user, targets, move)
          return if user != @target

          user.ability_used = false
        end
      end
      register(:mold_breaker, MoldBreaker)
    end
  end
end
