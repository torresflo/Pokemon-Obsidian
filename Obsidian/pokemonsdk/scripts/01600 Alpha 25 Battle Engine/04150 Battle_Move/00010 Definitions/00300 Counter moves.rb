module Battle
  class Move
    # When hit by a Physical Attack, user strikes back with 2x power.
    # @see https://pokemondb.net/move/counter
    # @see https://bulbapedia.bulbagarden.net/wiki/Counter_(move)
    # @see https://www.pokepedia.fr/Riposte_(capacit%C3%A9)
    class Counter < Basic
      include Mechanics::Counter

      private

      # Test if the attack fails
      # @param attacker [PFM::PokemonBattler] the last attacker
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @return [Boolean] does the attack fails ?
      def counter_fails?(attacker, user, targets)
        !attacker || logic.allies_of(user).include?(attacker) || attacker.type_ghost? || !attacker.move_history.last.move.physical?
      end
    end
    Move.register(:s_counter, Counter)

    # When hit by a Special Attack, user strikes back with 2x power.
    # @see https://pokemondb.net/move/mirror-coat
    # @see https://bulbapedia.bulbagarden.net/wiki/Mirror_Coat_(move)
    # @see https://www.pokepedia.fr/Voile_Miroir
    class MirrorCoat < Basic
      include Mechanics::Counter

      private

      # Test if the attack fails
      # @param attacker [PFM::PokemonBattler] the last attacker in this round
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @return [Boolean] does the attack fails ?
      def counter_fails?(attacker, user, targets)
        !attacker || logic.allies_of(user).include?(attacker) || attacker.type_dark? || !attacker.move_history.last.move.special?
      end
    end
    Move.register(:s_mirror_coat, MirrorCoat)

    # Deals damage equal to 1.5x opponent's attack.
    # @see https://pokemondb.net/move/metal-burst
    # @see https://bulbapedia.bulbagarden.net/wiki/Metal_Burst_(move)
    # @see https://www.pokepedia.fr/Fulmifer
    class MetalBurst < Basic
      include Mechanics::Counter

      private

      # Test if the attack fails
      # @param attacker [PFM::PokemonBattler] the last attacker
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @return [Boolean] does the attack fails ?
      def counter_fails?(attacker, user, targets)
        !attacker || logic.allies_of(user).include?(attacker) || !attacker.move_history.last.move.special? || !attacker.move_history.last.move.physical?
      end

      # Damage multiplier if the effect proc
      # @return [Integer, Float]
      def damage_multiplier
        1.5
      end
    end
    Move.register(:s_metal_burst, MetalBurst)
  end
end
