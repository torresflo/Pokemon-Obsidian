module Battle
  class Move
    # Move that inflict a critical hit
    class FullCrit < Basic
      # Return the critical rate index of the skill
      # @return [Integer]
      def critical_rate
        return 100
      end
    end

    Move.register(:s_full_crit, FullCrit)
  end
end
