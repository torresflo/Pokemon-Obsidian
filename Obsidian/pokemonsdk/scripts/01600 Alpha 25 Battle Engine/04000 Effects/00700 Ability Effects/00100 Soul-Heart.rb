module Battle
  module Effects
    class Ability
      class SoulHeart < Ability
        # Create a new FlowerGift effect
        # @param logic [Battle::Logic]
        # @param target [PFM::PokemonBattler]
        # @param db_symbol [Symbol] db_symbol of the ability
        def initialize(logic, target, db_symbol)
          super
          @affect_allies = true
        end

        # Function called after damages were applied and when target died (post_damage_death)
        # @param handler [Battle::Logic::DamageHandler]
        # @param hp [Integer] number of hp (damage) dealt
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def on_post_damage_death(handler, hp, target, launcher, skill)
          return if target.bank != @target.bank || launcher == target || target == @target

          if handler.logic.stat_change_handler.stat_increasable?(:ats, @target)
            handler.scene.visual.show_ability(@target)
            handler.logic.stat_change_handler.stat_change_with_process(:ats, 1, @target)
          end
        end
      end
      register(:"soul_heart", SoulHeart)
    end
  end
end
