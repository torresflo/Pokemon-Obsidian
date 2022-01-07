module Battle
  class Move
    # Echoed Voice deals damage starting at base power 40, and increases by 40 each turn if used by any
    # Pokémon on the field, up to a maximum base power of 200.
    # @see https://pokemondb.net/move/echoed-voice
    # @see https://bulbapedia.bulbagarden.net/wiki/Echoed_Voice_(move)
    # @see https://www.pokepedia.fr/%C3%89cho_(capacit%C3%A9)
    class EchoedVoice < BasicWithSuccessfulEffect
      # Get the real base power of the move (taking in account all parameter)
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def real_base_power(user, target)
        mod = logic.terrain_effects.get(:echoed_voice)&.successive_turns || 1
        real_power = (super + (echo_boost * mod)).clamp(0, max_power)
        log_data("power = #{real_power} # echoed voice successive turns #{mod}")
        return real_power
      end

      private

      # Internal procedure of the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      def proceed_internal(user, targets)
        logic.terrain_effects.add(Effects::EchoedVoice.new(logic)) unless logic.terrain_effects.has?(:echoed_voice)
        logic.terrain_effects.get(:echoed_voice).increase
        super
      end

      # Boost added to the power for each turn where the move has been used
      # @return [Integer]
      def echo_boost
        40
      end

      # Maximum value of the power
      # @return [Integer]
      def max_power
        200
      end
    end
    register(:s_echo, EchoedVoice)
  end
end
