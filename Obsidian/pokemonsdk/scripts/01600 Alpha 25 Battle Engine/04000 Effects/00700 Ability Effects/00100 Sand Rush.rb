module Battle
  module Effects
    class Ability
      class SandRush < Ability
        # Give the speed modifier over given to the Pokemon with this effect
        # @return [Float, Integer] multiplier
        def spd_modifier
          return $env.sandstorm? ? 2 : 1
        end
      end
      register(:sand_rush, SandRush)
    end
  end
end
