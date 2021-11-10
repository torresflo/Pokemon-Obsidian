module Battle
  class Move
    # Spit Up deals varying damage depending on how many times the user used Stockpile.
    # @see https://pokemondb.net/move/spit-up
    # @see https://bulbapedia.bulbagarden.net/wiki/Spit_Up_(move)
    # @see https://www.pokepedia.fr/Rel%C3%A2che
    class SpitUp < BasicWithSuccessfulEffect
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super
        return show_usage_failure(user) && false unless user.effects.get(effect_name)&.usable?

        return true
      end

      # Get the real base power of the move (taking in account all parameter)
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def real_base_power(user, target)
        effect = user.effects.get(effect_name)
        power = 100 * (effect&.stockpile || 1)
        log_data("# power = #{power} <stockpile:#{effect&.stockpile || 1}>")
        return power
      end

      private

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        user.effects.get(effect_name).use
      end

      # Name of the effect
      # @return [Symbol]
      def effect_name
        :stockpile
      end
    end
    Move.register(:s_split_up, SpitUp)
  end
end
