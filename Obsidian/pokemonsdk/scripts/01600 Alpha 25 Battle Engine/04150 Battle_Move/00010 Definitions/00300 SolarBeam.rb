module Battle
  class Move
    # The user of Solar Beam will absorb light on the first turn. On the second turn, Solar Beam deals damage.
    # @see https://pokemondb.net/move/solar-beam
    # @see https://bulbapedia.bulbagarden.net/wiki/Solar_Beam_(move)
    # @see https://www.pokepedia.fr/Lance-Soleil
    class SolarBeam < Basic
      include Mechanics::TwoTurn

      # Get the real base power of the move (taking in account all parameter)
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def real_base_power(user, target)
        power2 = power
        power2 *= 0.5 if $env.sandstorm? || $env.hail? || $env.rain?
        return power2
      end

      private

      # Check if the two turn move is executed in one turn
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @return [Boolean]
      def shortcut?(user, targets)
        return true if $env.sunny?

        return two_turns_shortcut?(user, targets)
      end

      # Display the message and the animation of the turn
      # @param user [PFM::PokemonBattler]
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      def proceed_message_turn1(user, targets)
        @scene.display_message_and_wait(parse_text_with_pokemon(19, 553, user))
      end
    end
    Move.register(:s_solar_beam, SolarBeam)
  end
end
