module Battle
  module Effects
    class Ability
      class Chlorophyll < Ability
        # Give the speed modifier over given to the Pokemon with this effect
        # @return [Float, Integer] multiplier
        def spd_modifier
          return $env.sunny? ? 2 : 1
        end
      end
      register(:chlorophyll, Chlorophyll)
    end
  end
end
