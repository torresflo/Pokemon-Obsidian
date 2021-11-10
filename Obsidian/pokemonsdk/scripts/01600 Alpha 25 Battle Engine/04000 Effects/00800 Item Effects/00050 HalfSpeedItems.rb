module Battle
  module Effects
    class Item
      class HalfSpeed < Item
        # Give the speed modifier over given to the Pokemon with this effect
        # @return [Float, Integer] multiplier
        def spd_modifier
          return 0.5
        end
      end
      register(:power_band, HalfSpeed)
      register(:power_belt, HalfSpeed)
      register(:power_bracer, HalfSpeed)
      register(:power_lens, HalfSpeed)
      register(:power_weight, HalfSpeed)
      register(:macho_brace, HalfSpeed)
      register(:iron_ball, HalfSpeed)
    end
  end
end
