module Battle
  module Effects
    class Item
      class AttackMultiplier < Item
        # List of conditions to yield the attack multiplier
        CONDITIONS = {}
        # List of multiplier if conditions are met
        MULTIPLIERS = Hash.new(2)
        # Give the move [Spe]atk mutiplier
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move] move
        # @return [Float, Integer] multiplier
        def sp_atk_multiplier(user, target, move)
          return 1 if user != @target
          return 1 unless CONDITIONS[db_symbol].call(user, target, move)

          return MULTIPLIERS[db_symbol]
        end

        class << self
          # Register an item with attack multiplier only
          # @param db_symbol [Symbol] db_symbol of the item
          # @param multiplier [Float] multiplier if condition met
          # @param klass [Class<AttackMultiplier>] klass to instanciate
          # @param block [Proc] condition to verify
          # @yieldparam user [PFM::PokemonBattler] user of the move
          # @yieldparam target [PFM::PokemonBattler] target of the move
          # @yieldparam move [Battle::Move] move
          # @yieldreturn [Boolean]
          def register(db_symbol, multiplier = nil, klass = AttackMultiplier, &block)
            Item.register(db_symbol, klass)
            CONDITIONS[db_symbol] = block
            MULTIPLIERS[db_symbol] = multiplier if multiplier
          end
        end

        class ChoiceAttackMultiplier < AttackMultiplier
          # Function called when we try to check if the user cannot use a move
          # @param user [PFM::PokemonBattler]
          # @param move [Battle::Move]
          # @return [Proc, nil]
          def on_move_disabled_check(user, move)
            return unless user == @target && user.move_history.any?
            return if user.move_history.last.db_symbol == move.db_symbol
            return if user.move_history.last.turn < user.last_sent_turn

            return proc {
              move.scene.visual.show_item(user)
              move.scene.display_message_and_wait(parse_text_with_pokemon(19, 911, user, PFM::Text::MOVE[1] => move.name))
            }
          end
        end

        class SoulDew < AttackMultiplier
          # Give the move [Spe]def mutiplier
          # @param user [PFM::PokemonBattler] user of the move
          # @param target [PFM::PokemonBattler] target of the move
          # @param move [Battle::Move] move
          # @return [Float, Integer] multiplier
          def sp_def_multiplier(user, target, move)
            return 1 if target != @target
            return 1 unless CONDITIONS[db_symbol].call(target, user, move)

            return MULTIPLIERS[db_symbol]
          end
        end
        register(:choice_band, 1.5, ChoiceAttackMultiplier) { |_, _, move| move.physical? }
        register(:choice_specs, 1.5, ChoiceAttackMultiplier) { |_, _, move| move.special? }
        register(:thick_club) { |user, _, move| move.physical? && %i[cubone marowak].include?(user.db_symbol) }
        register(:deep_sea_tooth) { |user, _, move| move.special? && user.db_symbol == :clamperl }
        register(:soul_dew, 1.5, SoulDew) { |user, _, move| move.special? && %i[latios latias].include?(user.db_symbol) }
      end
    end
  end
end
