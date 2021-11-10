module Battle
  module Effects
    class Ability
      class SlushRush < Ability
        # Give the speed modifier over given to the Pokemon with this effect
        # @return [Float, Integer] multiplier
        def spd_modifier
          return $env.hail? ? 2 : 1
        end
      end
      register(:slush_rush, SlushRush)
    end
  end
end
