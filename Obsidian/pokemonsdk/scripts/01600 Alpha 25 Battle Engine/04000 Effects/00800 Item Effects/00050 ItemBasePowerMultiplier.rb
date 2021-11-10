module Battle
  module Effects
    class Item
      class BasePowerMultiplier < Item
        # List of conditions to yield the base power multiplier
        CONDITIONS = {}
        # List of multiplier if conditions are met
        MULTIPLIERS = Hash.new(1.2)
        # Give the move base power mutiplier
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move] move
        # @return [Float, Integer] multiplier
        def base_power_multiplier(user, target, move)
          return 1 if user != @target
          return 1 unless CONDITIONS[db_symbol].call(user, target, move)

          return MULTIPLIERS[db_symbol]
        end

        class << self
          # Register an item with base power multiplier only
          # @param db_symbol [Symbol] db_symbol of the item
          # @param multiplier [Float] multiplier if condition met
          # @param klass [Class<BasePowerMultiplier>] klass to instanciate
          # @param block [Proc] condition to verify
          # @yieldparam user [PFM::PokemonBattler] user of the move
          # @yieldparam target [PFM::PokemonBattler] target of the move
          # @yieldparam move [Battle::Move] move
          # @yieldreturn [Boolean]
          def register(db_symbol, multiplier = nil, klass = BasePowerMultiplier, &block)
            Item.register(db_symbol, klass)
            CONDITIONS[db_symbol] = block
            MULTIPLIERS[db_symbol] = multiplier if multiplier
          end
        end

        register(:sea_incense) { |_, _, move| move.type_water? }
        register(:odd_incense) { |_, _, move| move.type_psychic? }
        register(:rock_incense) { |_, _, move| move.type_rock? }
        register(:wave_incense) { |_, _, move| move.type_water? }
        register(:rose_incense) { |_, _, move| move.type_grass? }
        register(:flame_plate) { |_, _, move| move.type_fire? }
        register(:splash_plate) { |_, _, move| move.type_water? }
        register(:zap_plate) { |_, _, move| move.type_electric? }
        register(:meadow_plate) { |_, _, move| move.type_grass? }
        register(:icicle_plate) { |_, _, move| move.type_ice? }
        register(:fist_plate) { |_, _, move| move.type_fighting? }
        register(:toxic_plate) { |_, _, move| move.type_poison? }
        register(:earth_plate) { |_, _, move| move.type_ground? }
        register(:sky_plate) { |_, _, move| move.type_flying? }
        register(:mind_plate) { |_, _, move| move.type_psychic? }
        register(:insect_plate) { |_, _, move| move.type_bug? }
        register(:stone_plate) { |_, _, move| move.type_rock? }
        register(:spooky_plate) { |_, _, move| move.type_ghost? }
        register(:draco_plate) { |_, _, move| move.type_dragon? }
        register(:dread_plate) { |_, _, move| move.type_dark? }
        register(:iron_plate) { |_, _, move| move.type_steel? }
        register(:pixie_plate) { |_, _, move| move.type_fairy? }
        register(:muscle_band, 1.1) { |_, _, move| move.physical? }
        register(:wise_glasses, 1.1) { |_, _, move| move.special? }
        register(:adamant_orb) { |user, _, move| user.db_symbol == :dialga && (move.type_dragon? || move.type_steel?) }
        register(:lustrous_orb) { |user, _, move| user.db_symbol == :palkia && (move.type_dragon? || move.type_water?) }
        register(:griseous_orb) { |user, _, move| user.db_symbol == :giratina && (move.type_dragon? || move.type_ghost?) }
      end
    end
  end
end
