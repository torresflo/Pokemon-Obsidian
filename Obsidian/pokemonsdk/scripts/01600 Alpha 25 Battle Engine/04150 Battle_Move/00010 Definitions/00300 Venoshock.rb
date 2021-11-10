module Battle
  class Move
    # Class managing Venoshock move
    class Venoshock < Basic
      # Method calculating the damages done by the actual move
      # @note : I used the 4th Gen formula : https://www.smogon.com/dp/articles/damage_formula
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def damages(user, target)
        dmg = super
        dmg *= 2 if target.poisoned? || target.toxic?
        log_data("PSDK Venoshock Damages: #{dmg}")

        return dmg
      end
    end

    Move.register(:s_venoshock, Venoshock)
  end
end
