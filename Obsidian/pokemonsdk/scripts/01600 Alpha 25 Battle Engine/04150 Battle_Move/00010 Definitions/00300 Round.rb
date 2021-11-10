module Battle
  class Move
    # Round deals damage. If multiple Pokémon on the same team use it in the same turn, the power doubles to 120 and the 
    # slower Pokémon move immediately after the fastest Pokémon uses it, regardless of their Speed.
    # @see https://pokemondb.net/move/round
    # @see https://bulbapedia.bulbagarden.net/wiki/Round_(move)
    # @see https://www.pokepedia.fr/Chant_Canon
    class Round < BasicWithSuccessfulEffect
      # Get the real base power of the move (taking in account all parameter)
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def real_base_power(user, target)
        mod = (any_allies_used_round?(user) ? 2 : 1)
        log_data("power * #{mod} # round #{mod == 1 ? 'not' : ''} used by an ally this turn.")
        return super * mod
      end

      private

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        logic.force_sort_actions do |a, b|
          next a <=> b unless a.is_a?(Actions::Attack) && b.is_a?(Actions::Attack)

          a_is_ally_and_round = logic.allies_of(user).include?(a.launcher) && a.move.db_symbol == :round
          b_is_ally_and_round = logic.allies_of(user).include?(b.launcher) && b.move.db_symbol == :round
          next b.launcher.speed <=> a.launcher.speed if a_is_ally_and_round && b_is_ally_and_round
          next 1 if a_is_ally_and_round
          next -1 if b_is_ally_and_round

          next a <=> b
        end
      end

      # Test if any ally had used round in the current turn
      # @param user [PFM::PokemonBattler]
      # @return [Boolean]
      def any_allies_used_round?(user)
        logic.allies_of(user).any? do |ally|
          return true if ally.move_history.any? { |mh| mh.current_turn? && mh.move.db_symbol == :round }
        end
        return false
      end
    end
    register(:s_round, Round)
  end
end
