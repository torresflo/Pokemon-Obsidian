module Battle
  class Move
    # Class describing a self stat move (damage + potential status + potential stat to user)
    class Growth < StatusStat
      def battle_stage_mod
        return super unless $env.sunny?

        return super.map { |i| i * 2 }
      end
    end
    Move.register(:s_growth, Growth)
  end
end
