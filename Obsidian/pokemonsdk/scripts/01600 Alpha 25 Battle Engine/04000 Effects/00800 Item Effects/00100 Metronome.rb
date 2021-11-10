module Battle
  module Effects
    class Item
      class Metronome < Item
        # Give the move mod1 mutiplier (after the critical)
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move] move
        # @return [Float, Integer] multiplier
        def mod2_multiplier(user, target, move)
          return 1 if user != @target || move.consecutive_use_count == 0
          return 2 if move.consecutive_use_count >= 10

          return 1 + move.consecutive_use_count / 10.0
        end
      end
      register(:metronome, Metronome)
    end
  end
end
