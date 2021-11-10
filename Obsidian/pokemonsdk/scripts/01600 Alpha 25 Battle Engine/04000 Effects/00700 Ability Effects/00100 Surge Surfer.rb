module Battle
  module Effects
    class Ability
      class SurgeSurfer < Ability
        # Give the speed modifier over given to the Pokemon with this effect
        # @return [Float, Integer] multiplier
        def spd_modifier
          return @logic.field_terrain_effect.electric? ? 2 : 1
        end
      end
      register(:surge_surfer, SurgeSurfer)
    end
  end
end
