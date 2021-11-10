module Battle
  class Move
    # Rototiller move
    class Rototiller < Move
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super

        if logic.all_alive_battlers.none?(&:type_grass?)
          show_usage_failure(user)
          return false
        end

        return true
      end

      # List the stats this move improves
      # @return [Array<Integer>]
      def battle_stage_mod
        [1, 0, 0, 1, 0, 0, 0]
      end

      private

      # Function that deals the stats to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_stats(user, actual_targets)
        super(user, logic.all_alive_battlers.select(&:type_grass?))
      end
    end
    Move.register(:s_rototiller, Rototiller)
  end
end
