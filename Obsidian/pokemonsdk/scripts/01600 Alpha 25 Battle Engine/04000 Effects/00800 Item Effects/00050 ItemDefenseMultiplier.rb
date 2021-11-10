module Battle
  module Effects
    class Item
      class DefenseMultiplier < Item
        # List of conditions to yield the defense multiplier
        CONDITIONS = {}
        # List of multiplier if conditions are met
        MULTIPLIERS = Hash.new(1.5)
        # Give the move [Spe]def mutiplier
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move] move
        # @return [Float, Integer] multiplier
        def sp_def_multiplier(user, target, move)
          return 1 if target != @target
          return 1 unless CONDITIONS[db_symbol].call(user, target, move)

          return MULTIPLIERS[db_symbol]
        end

        class << self
          # Register an item with defense multiplier only
          # @param db_symbol [Symbol] db_symbol of the item
          # @param multiplier [Float] multiplier if condition met
          # @param klass [Class<DefenseMultiplier>] klass to instanciate
          # @param block [Proc] condition to verify
          # @yieldparam user [PFM::PokemonBattler] user of the move
          # @yieldparam target [PFM::PokemonBattler] target of the move
          # @yieldparam move [Battle::Move] move
          # @yieldreturn [Boolean]
          def register(db_symbol, multiplier = nil, klass = DefenseMultiplier, &block)
            Item.register(db_symbol, klass)
            CONDITIONS[db_symbol] = block
            MULTIPLIERS[db_symbol] = multiplier if multiplier
          end
        end

        class AssaultVest < DefenseMultiplier
          # Function called when we try to check if the user cannot use a move
          # @param user [PFM::PokemonBattler]
          # @param move [Battle::Move]
          # @return [Proc, nil]
          def on_move_disabled_check(user, move)
            return unless move.status? && user == @target

            return proc { move.scene.display_message_and_wait(parse_text_with_pokemon(19, 911, user, PFM::Text::MOVE[1] => move.name)) }
          end
        end

        register(:metal_powder) do |_, target|
          next false if target.db_symbol != :ditto

          next target.move_history.none? do |move_history|
            move_history.db_symbol == :transform
          end
        end
        register(:eviolite) do |_, target|
          data = target.data
          next (data.special_evolution && !data.special_evolution.empty?) || data.evolution_id.to_i != 0
        end
        register(:deep_sea_scale, 2) { |_, target, move| move.special? && target.db_symbol == :clamperl }
        register(:assault_vest, nil, AssaultVest) { |_, _, move| move.special? }
      end
    end
  end
end
