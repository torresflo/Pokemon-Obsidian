module Battle
  module Effects
    class Ability
      class BoostingMoveType < Ability
        # Initial condition to give the power increase
        POWER_INCREASE_CONDITION = Hash.new(proc { true })
        # Type condition to give the power increase
        TYPE_CONDITION = Hash.new(GameData::Types::NORMAL)
        # Power increase if all condition are met
        POWER_INCREASE = Hash.new(1.5)

        # Get the base power multiplier of this move
        # @param user [PFM::PokemonBattler]
        # @param target [PFM::PokemonBattler]
        # @param move [Battle::Move]
        # @return [Float]
        def base_power_multiplier(user, target, move)
          return 1 if user != self.target
          return 1 unless POWER_INCREASE_CONDITION[@db_symbol].call(user, target, move)
          return 1 if move.type != TYPE_CONDITION[@db_symbol]

          return POWER_INCREASE[@db_symbol]
        end

        class << self
          # Register a BoostingMoveType ability
          # @param db_symbol [Symbol] db_symbol of the ability
          # @param type [Integer] move type getting power increase
          # @param multiplier [Float] multiplier if all condition are meet
          # @param block [Proc] additional condition
          # @yieldparam user [PFM::PokemonBattler]
          # @yieldparam target [PFM::PokemonBattler]
          # @yieldparam move [Battle::Move]
          # @yieldreturn [Boolean]
          def register(db_symbol, type, multiplier = nil, &block)
            POWER_INCREASE_CONDITION[db_symbol] = block if block
            TYPE_CONDITION[db_symbol] = type
            POWER_INCREASE[db_symbol] = multiplier if multiplier
            Ability.register(db_symbol, BoostingMoveType)
          end
        end

        register(:blaze, GameData::Types::FIRE) { |user| user.hp_rate <= 0.333 }
        register(:overgrow, GameData::Types::GRASS) { |user| user.hp_rate <= 0.333 }
        register(:torrent, GameData::Types::WATER) { |user| user.hp_rate <= 0.333 }
        register(:swarm, GameData::Types::BUG) { |user| user.hp_rate <= 0.333 }
        register(:"dragon's maw", GameData::Types::DRAGON)
        register(:steelworker, GameData::Types::STEEL)
        register(:transitor, GameData::Types::ELECTRIC)
      end
    end
  end
end
