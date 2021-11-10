module Battle
  class Move
    # Power depends on held item.
    # @see https://pokemondb.net/move/fling
    # @see https://bulbapedia.bulbagarden.net/wiki/Fling_(move)
    # @see https://www.pokepedia.fr/D%C3%A9gommage
    class Fling < Basic
      include Mechanics::PowerBasedOnItem
      private

      # Tell if the item is consumed during the attack
      # @return [Boolean]
      def consume_item?
        true
      end

      # Test if the held item is valid
      # @param name [Symbol]
      # @return [Boolean]
      def valid_held_item?(name)
        (GameData::Item[name].fling_power || 0) > 0
      end

      # Get the real power of the move depending on the item
      # @param name [Symbol]
      # @return [Integer]
      def get_power_by_item(name)
        GameData::Item[name].fling_power || 0
      end
    end
    Move.register(:s_fling, Fling)
  end
end