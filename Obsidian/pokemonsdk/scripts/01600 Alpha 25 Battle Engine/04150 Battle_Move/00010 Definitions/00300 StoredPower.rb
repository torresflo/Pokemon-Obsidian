module Battle
  class Move
    # Move that deals more damage if user has any stat boost
    class StoredPower < Basic
      # Get the real base power of the move (taking in account all parameter)
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def real_base_power(user, target)
        base_power = db_symbol == :stored_power ? 20 : 60
        stat_count = stat_increase_count(user)
        stat_count = stat_count.clamp(0, 7) if db_symbol == :punishment
        return 20 * stat_count + base_power
      end

      private

      # Get the number of increased stats
      # @param user [PFM::PokemonBattler] user of the move
      # @return [Integer]
      def stat_increase_count(user)
        return user.atk_stage.clamp(0, Float::INFINITY) +
               user.dfe_stage.clamp(0, Float::INFINITY) +
               user.spd_stage.clamp(0, Float::INFINITY) +
               user.ats_stage.clamp(0, Float::INFINITY) +
               user.dfs_stage.clamp(0, Float::INFINITY) +
               user.acc_stage.clamp(0, Float::INFINITY) +
               user.eva_stage.clamp(0, Float::INFINITY)
      end
    end

    Move.register(:s_stored_power, StoredPower)
  end
end
