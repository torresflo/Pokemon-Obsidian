module Battle
  module Effects
    class Ability
      class Unburden < Ability
        # Give the speed modifier over given to the Pokemon with this effect
        # @return [Float, Integer] multiplier
        def spd_modifier
          return 1 if target.item_holding >= 0

          return @target.item_holding == target.original.item_holding ? 1 : 2
        end

        # Function called when a post_item_change is checked
        # @param handler [Battle::Logic::ItemChangeHandler]
        # @param db_symbol [Symbol] Symbol ID of the item
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def on_post_item_change(handler, db_symbol, target, launcher, skill)
          return unless db_symbol == :none

          if (st_ch = handler.logic.stat_change_handler).stat_increasable?(:spd, target)
            handler.scene.visual.show_ability(target)
            st_ch.stat_change(:spd, 1, target)
          end
          st_ch.reset_prevention_reason
        end
      end
      register(:unburden, Unburden)
    end
  end
end
