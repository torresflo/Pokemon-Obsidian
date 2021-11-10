module Battle
  class Move
    # Accuracy depends of weather.
    # @see https://pokemondb.net/move/thunder
    # @see https://bulbapedia.bulbagarden.net/wiki/Thunder_(move)
    # @see https://www.pokepedia.fr/Fatal-Foudre
    class Thunder < Basic
      # Return the current accuracy of the move
      # @return [Integer]
      def accuracy
        al = @scene.logic.all_alive_battlers.any? { |battler| battler.has_ability?(:cloud_nine) || battler.has_ability?(:air_lock) }
        return super if al
        return 50 if $env.sunny?
        return 0 if $env.rain?

        return super
      end
    end
    Move.register(:s_thunder, Thunder)
    Move.register(:s_hurricane, Thunder)
  end
end
