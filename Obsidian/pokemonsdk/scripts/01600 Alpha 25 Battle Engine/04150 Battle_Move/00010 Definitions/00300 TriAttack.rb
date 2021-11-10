module Battle
  class Move
    # Class managing moves that deal a status between three ones
    class TriAttack < Basic

      # Function that deals the status condition to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_status(user, actual_targets)
        return true if status_effect.to_i <= 0

        status = %i[paralysis burn freeze].sample(random: @logic.generic_rng)
        actual_targets.each do |target|
          @logic.status_change_handler.status_change_with_process(status, target, user, self)
        end
      end
    end

    Move.register(:s_tri_attack, TriAttack)
  end
end
