module Battle
  class Move
    # Type depends on the Arceus Plate being held.
    # @see https://pokemondb.net/move/judgment
    # @see https://bulbapedia.bulbagarden.net/wiki/Judgment_(move)
    # @see https://www.pokepedia.fr/Jugement
    class Judgment < Basic
      include Mechanics::TypesBasedOnItem
      private

      # Tell if the item is consumed during the attack
      # @return [Boolean]
      def consume_item?
        false
      end
      
      # Test if the held item is valid
      # @param name [Symbol]
      # @return [Boolean]
      def valid_held_item?(name)
        JUDGMENT_TABLE.keys.include?(name)
      end

      # Get the real types of the move depending on the item
      # @param name [Symbol]
      # @return [Array<Integer>]
      def get_types_by_item(name)
        JUDGMENT_TABLE[name]
      end

      # Table of move type depending on item
      # @return [Hash<Symbol, Array<Integer>>]
      JUDGMENT_TABLE = {
        flame_plate:  [GameData::Types::FIRE],
        splash_plate:  [GameData::Types::WATER],
        zap_plate:  [GameData::Types::ELECTRIC],
        meadow_plate:  [GameData::Types::GRASS],
        icicle_plate:  [GameData::Types::ICE],
        fist_plate:  [GameData::Types::FIGHTING],
        toxic_plate:  [GameData::Types::POISON],
        earth_plate:  [GameData::Types::GROUND],
        sky_plate:  [GameData::Types::FLYING],
        mind_plate:  [GameData::Types::PSYCHIC],
        insect_plate:  [GameData::Types::BUG],
        stone_plate:  [GameData::Types::ROCK],
        spooky_plate:  [GameData::Types::GHOST],
        draco_plate:  [GameData::Types::DRAGON],
        iron_plate:  [GameData::Types::STEEL],
        dread_plate:  [GameData::Types::DARK],
        pixie_plate:  [GameData::Types::FAIRY],
      }
    end
    Move.register(:s_judgment, Judgment)
  end
end