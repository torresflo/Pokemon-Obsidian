module Battle
  class Move
    # Class managing moves that deal damages equivalent level
    class HPEqLevel < Basic
      private

      # Method calculating the damages done by the actual move
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def damages(user, target)
        @critical = false
        @effectiveness = 1
        log_data("Damages equivalent to the user Level Move: #{user.level} HP")
        return user.level || 1
      end
    end

    Move.register(:s_hp_eq_level, HPEqLevel)
  end
end
