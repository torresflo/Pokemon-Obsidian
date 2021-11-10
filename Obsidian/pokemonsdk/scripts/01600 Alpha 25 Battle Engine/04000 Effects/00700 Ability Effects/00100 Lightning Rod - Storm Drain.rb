module Battle
  module Effects
    class Ability
      class LightningRod < Ability
        # List of effect that prevent Lightning Rod from working
        BLOCKING_EFFECTS = %i[rage_powder follow_me]
        # Create a new FlowerGift effect
        # @param logic [Battle::Logic]
        # @param target [PFM::PokemonBattler]
        # @param db_symbol [Symbol] db_symbol of the ability
        def initialize(logic, target, db_symbol)
          super
          @affect_allies = true
        end

        # Function called when a damage_prevention is checked
        # @param handler [Battle::Logic::DamageHandler]
        # @param hp [Integer] number of hp (damage) dealt
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        # @return [:prevent, Integer, nil] :prevent if the damage cannot be applied, Integer if the hp variable should be updated
        def on_damage_prevention(handler, hp, target, launcher, skill)
          return unless move_check?(skill)
          return unless launcher&.can_be_lowered_or_canceled?
          return unless @logic.all_alive_battlers.any? { |battler| BLOCKING_EFFECTS.any? { |e| battler.effects.has?(e) } }

          return handler.prevent_change do
            handler.scene.visual.show_ability(@target)
            handler.logic.stat_change_handler.stat_change_with_process(:ats, 1, @target)
          end
        end

        private

        # Check the type of the move
        # @param move [Battle::Move, nil] Potential move used
        # @return [Boolean]
        def move_check?(move)
          return move&.type_electric? || false
        end
      end
      register(:lightning_rod, LightningRod)

      class StormDrain < LightningRod
        private

        # Check the type of the move
        # @param move [Battle::Move, nil] Potential move used
        # @return [Boolean]
        def move_check?(move)
          return move&.type_water? || false
        end
      end
      register(:storm_drain, StormDrain)
    end
  end
end
