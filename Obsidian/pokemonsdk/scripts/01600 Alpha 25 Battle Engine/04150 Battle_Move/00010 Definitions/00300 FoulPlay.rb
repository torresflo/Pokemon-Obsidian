module Battle
  class Move
    # Class managing Foul Play move
    class FoulPlay < Basic
      # Get the basis atk for the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @param ph_move [Boolean] true: physical, false: special
      # @return [Integer]
      def calc_sp_atk_basis(user, target, ph_move)
        return ph_move ? target.atk_basis : target.ats_basis
      end

      # Statistic modifier calculation: ATK/ATS
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @param ph_move [Boolean] true: physical, false: special
      # @return [Integer]
      def calc_atk_stat_modifier(user, target, ph_move)
        return 1 if critical_hit?

        return ph_move ? target.atk_modifier : target.ats_modifier
      end
    end
    Move.register(:s_foul_play, FoulPlay)
  end
end
