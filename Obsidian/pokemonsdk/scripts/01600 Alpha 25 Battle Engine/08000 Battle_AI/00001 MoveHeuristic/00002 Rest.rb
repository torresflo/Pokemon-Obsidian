module Battle
  module AI
    class MoveHeuristicBase
      class Rest < MoveHeuristicBase
        # Create a new Rest Heuristic
        def initialize
          super(true, true, true)
        end

        # Compute the heuristic
        # @param move [Battle::Move]
        # @param user [PFM::PokemonBattler]
        # @param target [PFM::PokemonBattler]
        # @param ai [Battle::AI::Base]
        # @return [Float]
        def compute(move, user, target, ai)
          boost = user.status_effect.instance_of?(Effects::Status) ? 0 : 1
          return (1 - user.hp_rate) * 2 + boost
        end
      end

      register(:s_rest, Rest, 1)
    end
  end
end
