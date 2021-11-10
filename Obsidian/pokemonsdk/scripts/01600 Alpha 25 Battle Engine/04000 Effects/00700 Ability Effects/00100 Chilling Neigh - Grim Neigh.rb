module Battle
  module Effects
    class Ability
      class ChillingNeigh < Ability
        # Function called after damages were applied and when target died (post_damage_death)
        # @param handler [Battle::Logic::DamageHandler]
        # @param hp [Integer] number of hp (damage) dealt
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def on_post_damage_death(handler, hp, target, launcher, skill)
          return if launcher != @target || launcher == target
          return unless launcher && launcher.hp > 0

          if handler.logic.stat_change_handler.stat_increasable?(boosted_stat, launcher)
            handler.scene.visual.show_ability(launcher)
            handler.logic.stat_change_handler.stat_change_with_process(boosted_stat, 1, launcher)
          end
        end

        private

        def boosted_stat
          return :atk
        end
      end
      register(:chilling_neigh, ChillingNeigh)

      class GrimNeigh < ChillingNeigh
        private

        def boosted_stat
          return :ats
        end
      end
      register(:grim_neigh, GrimNeigh)
    end
  end
end
