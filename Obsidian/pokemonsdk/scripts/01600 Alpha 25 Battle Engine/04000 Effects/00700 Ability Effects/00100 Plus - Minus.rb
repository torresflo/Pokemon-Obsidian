module Battle
  module Effects
    class Ability
      class Plus < Ability
        # Give the move [Spe]atk mutiplier
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move] move
        # @return [Float, Integer] multiplier
        def sp_atk_multiplier(user, target, move)
          return 1 if user != @target
          return 1 unless move.logic.allies_of(user).any? { |ally| ally.ability_effect.is_a?(Plus) }

          return move.special? ? 1.5 : 1
        end
      end
      register(:plus, Plus)
      register(:minus, Plus)
    end
  end
end
