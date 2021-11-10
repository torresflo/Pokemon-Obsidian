module Battle
  class Move
    class HeavySlam < Basic
      MINIMUM_WEIGHT_PERCENT = [0.5, 0.3334, 0.25, 0.20]
      # Get the real base power of the move (taking in account all parameter)
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def real_base_power(user, target)
        weight_percent = target.weight.to_f / user.weight
        weight_index = MINIMUM_WEIGHT_PERCENT.find_index { |weight| weight_percent > weight } || MINIMUM_WEIGHT_PERCENT.size
        minimize_factor = target.effects.has?(:minimize) ? 2 : 1
        return (40 + 20 * weight_index) * minimize_factor
      end

      # Check if the move bypass chance of hit and cannot fail
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Boolean]
      def bypass_chance_of_hit?(user, target)
        return true if target.effects.has?(:minimize)

        super
      end
    end

    Move.register(:s_heavy_slam, HeavySlam)
  end
end
