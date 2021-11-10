module Battle
  class Move
    # Inflict Sacred Sword to an enemy (ignore evasion and defense stats change)
    class SacredSword < Basic
      # Return the evasion modifier of the target
      # @param _target [PFM::PokemonBattler]
      # @return [Float]
      def evasion_mod(_target)
        return 1
      end

      # Statistic modifier calculation: DFE/DFS
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @param ph_move [Boolean] true: physical, false: special
      # @return [Integer]
      def calc_def_stat_modifier(user, target, ph_move)
        return 1
      end
    end
    Move.register(:s_sacred_sword, SacredSword)
  end
end
