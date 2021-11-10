module Battle
  class Move
    # Feint has an increased power if the target used Protect or Detect during this turn. It lift the effects of protection moves.
    # @see https://pokemondb.net/move/feint
    # @see https://bulbapedia.bulbagarden.net/wiki/Feint_(move)
    # @see https://www.pokepedia.fr/Ruse
    class Feint < BasicWithSuccessfulEffect
      # Get the real base power of the move (taking in account all parameter)
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def real_base_power(user, target)
        return increased_power if target.move_history.any? && increased_power_move?(target.move_history.last)

        return super
      end

      # Detect if the move is protected by another move on target
      # @param target [PFM::PokemonBattler]
      # @param symbol [Symbol]
      def blocked_by?(target, symbol)
        return false unless super

        return !target.effects.has?(:protect)
      end

      private

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          target.effects.each do |effect|
            next unless lifted_effect?(effect)

            effect.kill
            scene.display_message_and_wait(deal_message(user, target, effect))
          end
        end
      end

      INCREASED_POWER_MOVES = %i[protect]

      # Does the move increase the attack power ?
      # @param move_history [PFM::PokemonBattler::MoveHistory]
      # @return [Boolean]
      def increased_power_move?(move_history)
        move_history.current_turn? && INCREASED_POWER_MOVES.include?(move_history.move.db_symbol)
      end

      # Increased power value
      # @return [Integer]
      def increased_power
        50
      end

      LIFTED_EFFECTS = %i[protect]

      # Is the effect lifted by the move
      # @param effect [Battle::Effects::EffectBase]
      # @return [Boolean]
      def lifted_effect?(effect)
        LIFTED_EFFECTS.include?(effect.name)
      end

      # Message display when the move lift an effect
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler]
      # @param effect [Battle::Effects::EffectBase]
      # @return [String]
      def deal_message(user, target, effect)
        parse_text_with_pokemon(19, 526, target)
      end
    end
    Move.register(:s_feint, Feint)
  end
end
