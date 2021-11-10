module Battle
  module Effects
    class Item
      class TypeResistingBerry < Berry
        # List of conditions to yield the attack multiplier
        CONDITIONS = {}
        # Give the move mod3 mutiplier (after everything)
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move] move
        # @return [Float, Integer] multiplier
        def mod3_multiplier(user, target, move)
          return 1 if cannot_be_consumed?
          return 1 if target != @target || !CONDITIONS[db_symbol].call(user, target, move)

          consume_berry(target, user, move)
          return 0.5
        end

        class << self
          # Register an item with defense multiplier only
          # @param db_symbol [Symbol] db_symbol of the item
          # @param klass [Class<TypeResistingBerry>] klass to instanciate
          # @param block [Proc] condition to verify
          # @yieldparam user [PFM::PokemonBattler] user of the move
          # @yieldparam target [PFM::PokemonBattler] target of the move
          # @yieldparam move [Battle::Move] move
          # @yieldreturn [Boolean]
          def register(db_symbol, klass = TypeResistingBerry, &block)
            Item.register(db_symbol, klass)
            CONDITIONS[db_symbol] = block
          end
        end
        register(:occa_berry) { |_, _, move| move.super_effective? && move.type_fire? }
        register(:passho_berry) { |_, _, move| move.super_effective? && move.type_water? }
        register(:wacan_berry) { |_, _, move| move.super_effective? && move.type_electric? }
        register(:rindo_berry) { |_, _, move| move.super_effective? && move.type_grass? }
        register(:yache_berry) { |_, _, move| move.super_effective? && move.type_ice? }
        register(:chople_berry) { |_, _, move| move.super_effective? && move.type_fighting? }
        register(:kebia_berry) { |_, _, move| move.super_effective? && move.type_poison? }
        register(:shuca_berry) { |_, _, move| move.super_effective? && move.type_ground? }
        register(:coba_berry) { |_, _, move| move.super_effective? && move.type_flying? }
        register(:payapa_berry) { |_, _, move| move.super_effective? && move.type_psychic? }
        register(:tanga_berry) { |_, _, move| move.super_effective? && move.type_bug? }
        register(:charti_berry) { |_, _, move| move.super_effective? && move.type_rock? }
        register(:kasib_berry) { |_, _, move| move.super_effective? && move.type_ghost? }
        register(:haban_berry) { |_, _, move| move.super_effective? && move.type_dragon? }
        register(:colbur_berry) { |_, _, move| move.super_effective? && move.type_dark? }
        register(:babiri_berry) { |_, _, move| move.super_effective? && move.type_steel? }
        register(:chilan_berry) { |_, _, move| move.type_normal? }
        register(:roseli_berry) { |_, _, move| move.super_effective? && move.type_fairy? }
      end
    end
  end
end
