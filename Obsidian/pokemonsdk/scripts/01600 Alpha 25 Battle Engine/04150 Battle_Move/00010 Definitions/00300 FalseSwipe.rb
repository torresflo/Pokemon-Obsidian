module Battle
  class Move
    class FalseSwipe < Basic
      # Method calculating the damages done by the actual move
      # @note : I used the 4th Gen formula : https://www.smogon.com/dp/articles/damage_formula
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def damages(user, target)
        hp_total = super
        hp_total = target.hp - 1 if hp_total >= target.hp
        return hp_total
      end
    end
    Move.register(:s_false_swipe, FalseSwipe)
  end
end
