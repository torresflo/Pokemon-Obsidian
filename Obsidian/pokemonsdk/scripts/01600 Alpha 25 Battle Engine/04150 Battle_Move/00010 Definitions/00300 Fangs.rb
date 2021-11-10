module Battle
  class Move
    # Class managing moves that deal a status or flinch
    class Fangs < Basic

      # Function that deals the status condition to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_status(user, actual_targets)
        return true if status_effect.to_i <= 0

        status = bchance?(0.5) ? STATUS_EFFECT_MAPPING[status_effect] : :flinch
        actual_targets.each do |target|
          @logic.status_change_handler.status_change_with_process(status, target, user, self)
        end
      end
    end

    Move.register(:s_a_fang, Fangs)
  end
end
