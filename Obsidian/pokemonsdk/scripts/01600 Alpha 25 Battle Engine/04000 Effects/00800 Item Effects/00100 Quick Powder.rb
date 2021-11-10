module Battle
  module Effects
    class Item
      class QuickPowder < Item
        # Give the speed modifier over given to the Pokemon with this effect
        # @return [Float, Integer] multiplier
        def spd_modifier
          return @target.db_symbol == :ditto ? 2 : 1
        end
      end
      register(:quick_powder, QuickPowder)
    end
  end
end
