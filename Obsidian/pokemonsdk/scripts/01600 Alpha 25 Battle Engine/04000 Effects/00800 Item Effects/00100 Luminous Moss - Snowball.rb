module Battle
  module Effects
    class Item
      class LuminousMoss < Item
        # Function called after damages were applied (post_damage, when target is still alive)
        # @param handler [Battle::Logic::DamageHandler]
        # @param hp [Integer] number of hp (damage) dealt
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def on_post_damage(handler, hp, target, launcher, skill)
          return if target != @target
          return unless expected_type?(skill)

          handler.scene.visual.show_item(target)
          handler.logic.stat_change_handler.stat_change_with_process(:dfs, 1, target)
          handler.logic.item_change_handler.change_item(:none, true, target)
        end

        private

        # Get the stat the item should improve
        # @return [Symbol]
        def stat_improved
          return :dfs
        end

        # Tell if the used skill triggers the effect
        # @param move [Battle::Move, nil] Potential move used
        # @return [Boolean]
        def expected_type?(move)
          return move&.type_water?
        end
      end

      class Snowball < LuminousMoss
        private

        # Get the stat the item should improve
        # @return [Symbol]
        def stat_improved
          return :atk
        end

        # Tell if the used skill triggers the effect
        # @param move [Battle::Move, nil] Potential move used
        # @return [Boolean]
        def expected_type?(move)
          return move&.type_ice?
        end
      end
      register(:luminous_moss, LuminousMoss)
      register(:snowball, Snowball)
    end
  end
end
