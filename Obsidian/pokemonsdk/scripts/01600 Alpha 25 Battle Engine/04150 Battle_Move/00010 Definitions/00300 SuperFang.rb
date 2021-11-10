module Battle
  class Move
    # Class managing Super Fang move
    class SuperFang < Basic
      # Method calculating the damages done by the actual move
      # @note : I used the 4th Gen formula : https://www.smogon.com/dp/articles/damage_formula
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def damages(user, target)
        @critical = false
        @effectiveness = 1
        log_data("Forced HP Move: #{(target.max_hp / 2).clamp(1, Float::INFINITY)} HP")
        return (target.max_hp / 2).clamp(1, Float::INFINITY)
      end
    end

    Move.register(:s_super_fang, SuperFang)
  end
end
