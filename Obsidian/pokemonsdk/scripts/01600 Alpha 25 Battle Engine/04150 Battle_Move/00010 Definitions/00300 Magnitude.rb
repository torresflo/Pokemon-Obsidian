module Battle
  class Move
    # Class managing Magnitude move
    # @see https://bulbapedia.bulbagarden.net/wiki/Magnitude_(move)
    # @see https://pokemondb.net/move/magnitude
    # @see https://www.pokepedia.fr/Ampleur
    class Magnitude < Basic
      # Get the real base power of the move (taking in account all parameter)
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def real_base_power(user, target)
        return magnitude_table[3][1] unless @magnitude_found # magnitude_found = nil when real_base_power called by AI
        log_data("magnitude power #{@magnitude_found[1]} # #{@magnitude_found}")
        power = @magnitude_found[1]
        @magnitude_found = nil
        return power
      end

      # Method calculating the damages done by the actual move
      # @note : I used the 4th Gen formula : https://www.smogon.com/dp/articles/damage_formula
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def damages(user, target)
        return super(user, target) unless (e = target.effects.get(&:out_of_reach?)) && !e&.on_move_prevention_target(user, target, self)

        d = super(user, target)
        log_data("damage = #{d * 2} # #{d} * 2 (magnitude overhall damages double when target is using dig)")
        return (d * 2).floor
      end

      private

      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super
        # Pick a random magnitude data
        dice = logic.generic_rng.rand(100).floor
        @magnitude_found = magnitude_table.find { |row| row[0] > dice } || magnitude_table[0]
        return true
      end

      # Show the move usage message
      # @param user [PFM::PokemonBattler] user of the move
      def usage_message(user)
        super
        @scene.display_message_and_wait(parse_text(18, @magnitude_found[2]))
      end

      # Damage table
      # Array<[probability_of_100, power, text]>
      # Sum of probabilities must be 100
      MAGNITUDE_TABLE = [
        [5, 10, 108],
        [15, 30, 109],
        [35, 50, 110],
        [65, 70, 111],
        [85, 90, 112],
        [95, 110, 113],
        [100, 150, 114]
      ]

      # Damage table
      # Array<[probability_of_100, power, text]>
      # Sum of probabilities must be 100
      def magnitude_table
        MAGNITUDE_TABLE
      end
    end
    Move.register(:s_magnitude, Magnitude)
  end
end
