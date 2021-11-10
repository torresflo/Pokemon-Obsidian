module Battle
  module Effects
    class Ability
      class SwiftSwim < Ability
        # Give the speed modifier over given to the Pokemon with this effect
        # @return [Float, Integer] multiplier
        def spd_modifier
          return $env.rain? ? 2 : 1
        end
      end
      register(:swift_swim, SwiftSwim)
    end
  end
end
