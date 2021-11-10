module Battle
  class Move
    # Fury Cutter starts with a base power of 10. Every time it is used successively, its power will double, up to a maximum of 160.
    # @see https://bulbapedia.bulbagarden.net/wiki/Fury_Cutter_(move)
    # @see https://pokemondb.net/move/fury-cutter
    # @see https://www.pokepedia.fr/Taillade
    class FuryCutter < BasicWithSuccessfulEffect
      # Get the real base power of the move (taking in account all parameter)
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def real_base_power(user, target)
        successive_uses = (user.effects.get(effect_name)&.successive_uses || 0) + 1
        fury_cutter_power = (super * 2**(successive_uses - 1)).clamp(0, max_power)
        log_data('power = %i # %s effect %i successive uses' % [fury_cutter_power, effect_name, successive_uses])
        return fury_cutter_power
      end

      private

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        user.effects.add(create_effect(user, actual_targets)) unless user.effects.has?(effect_name)
        user.effects.get(effect_name).increase
      end

      # Max base power of the move.
      # @return [Integer]
      def max_power
        160
      end

      # Class of the effect
      # @return [Symbol]
      def effect_name
        :fury_cutter
      end

      # Create the move effect object
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      # @return [Battle::Effects::EffectBase]
      def create_effect(user, actual_targets)
        Battle::Effects::FuryCutter.new(logic, user, self)
      end
    end
    Move.register(:s_fury_cutter, FuryCutter)
  end
end
