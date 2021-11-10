module Battle
  class Move
    # Stockpile raises the user's Defense and Special Defense by one stage each and charges up power for use with companion moves Spit Up or Swallow.
    # @see https://pokemondb.net/move/stockpile
    # @see https://bulbapedia.bulbagarden.net/wiki/Stockpile_(move)
    # @see https://www.pokepedia.fr/Stockage
    class Stockpile < Move
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super
        return show_usage_failure(user) && false unless targets.any? { |target| !target.effects.has?(effect_name) || target.effects.get(effect_name).increasable? }

        return true
      end

      private

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          target.effects.add(create_effect(user, target)) unless target.effects.has?(effect_name)
          target.effects.get(effect_name).increase
        end
      end

      # Name of the effect
      # @return [Symbol]
      def effect_name
        :stockpile
      end

      # Create the effect
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target that will be affected by the move
      def create_effect(user, target)
        return Effects::Stockpile.new(logic, target)
      end
    end
    Move.register(:s_stockpile, Stockpile)
  end
end
