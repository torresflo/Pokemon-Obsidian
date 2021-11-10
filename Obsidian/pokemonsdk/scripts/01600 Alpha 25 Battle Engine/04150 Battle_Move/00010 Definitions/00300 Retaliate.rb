module Battle
  class Move
    # Inflicts double damage if a teammate fainted on the last turn.
    class Retaliate < Basic
      # Get the real base power of the move (taking in account all parameter)
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def real_base_power(user, target)
        check = @logic.all_battlers.any? { |battler|
          battler.from_party? && battler.damage_history.any? { |history| history.ko && history.last_turn? }
        }
        return check ? power * 2 : power
      end
    end
    Move.register(:s_retaliate, Retaliate)
  end
end
