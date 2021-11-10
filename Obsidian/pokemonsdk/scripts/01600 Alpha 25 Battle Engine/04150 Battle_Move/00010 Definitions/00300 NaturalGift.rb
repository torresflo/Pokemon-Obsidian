module Battle
  class Move
    # Natural Gift deals damage with no additional effects. However, its type and base power vary depending on the user's held Berry. 
    # @see https://pokemondb.net/move/natural-gift
    # @see https://bulbapedia.bulbagarden.net/wiki/Natural_Gift_(move)
    # @see https://www.pokepedia.fr/Don_Naturel
    class NaturalGift < Basic
      include Mechanics::PowerBasedOnItem
      include Mechanics::TypesBasedOnItem

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
        NATURAL_GIFT_TABLE.keys.include?(name)
      end

      # Get the real power of the move depending on the item
      # @param name [Symbol]
      # @return [Integer]
      def get_power_by_item(name)
        NATURAL_GIFT_TABLE[name][0]
      end

      # Get the real types of the move depending on the item
      # @param name [Symbol]
      # @return [Array<Integer>]
      def get_types_by_item(name)
        NATURAL_GIFT_TABLE[name][1]
      end

      class << self
        def reset
          const_set(:NATURAL_GIFT_TABLE, {})
        end

        def register(berry, power, *types)
          NATURAL_GIFT_TABLE[berry] ||= []
          NATURAL_GIFT_TABLE[berry] = [power, types]
        end
      end

      reset
      register(:chilan_berry, 80, GameData::Types::NORMAL)

      register(:cheri_berry, 80, GameData::Types::FIRE)
      register(:occa_berry, 80, GameData::Types::FIRE)
      register(:bluk_berry, 90, GameData::Types::FIRE)
      register(:watmel_berry, 100, GameData::Types::FIRE)

      register(:chesto_berry, 80, GameData::Types::WATER)
      register(:passho_berry, 80, GameData::Types::WATER)
      register(:nanab_berry, 90, GameData::Types::WATER)
      register(:durin_berry, 100, GameData::Types::WATER)

      register(:pecha_berry, 80, GameData::Types::ELECTRIC)
      register(:wacan_berry, 80, GameData::Types::ELECTRIC)
      register(:wepear_berry, 90, GameData::Types::ELECTRIC)
      register(:belue_berry, 100, GameData::Types::ELECTRIC)

      register(:rawst_berry, 80, GameData::Types::GRASS)
      register(:rindo_berry, 80, GameData::Types::GRASS)
      register(:pinap_berry, 90, GameData::Types::GRASS)
      register(:liechi_berry, 100, GameData::Types::GRASS)

      register(:aspear_berry, 80, GameData::Types::ICE)
      register(:yache_berry, 80, GameData::Types::ICE)
      register(:pomeg_berry, 90, GameData::Types::ICE)
      register(:ganlon_berry, 100, GameData::Types::ICE)

      register(:leppa_berry, 80, GameData::Types::FIGHTING)
      register(:chople_berry, 80, GameData::Types::FIGHTING)
      register(:kelpsy_berry, 90, GameData::Types::FIGHTING)
      register(:salac_berry, 100, GameData::Types::FIGHTING)

      register(:oran_berry, 80, GameData::Types::POISON)
      register(:kebia_berry, 80, GameData::Types::POISON)
      register(:qualot_berry, 90, GameData::Types::POISON)
      register(:petaya_berry, 100, GameData::Types::POISON)

      register(:persim_berry, 80, GameData::Types::GROUND)
      register(:shuca_berry, 80, GameData::Types::GROUND)
      register(:hondew_berry, 90, GameData::Types::GROUND)
      register(:apicot_berry, 100, GameData::Types::GROUND)

      register(:lum_berry, 80, GameData::Types::FLYING)
      register(:coba_berry, 80, GameData::Types::FLYING)
      register(:grepa_berry, 90, GameData::Types::FLYING)
      register(:lansat_berry, 100, GameData::Types::FLYING)

      register(:sitrus_berry, 80, GameData::Types::PSYCHIC)
      register(:payapa_berry, 80, GameData::Types::PSYCHIC)
      register(:tamato_berry, 90, GameData::Types::PSYCHIC)
      register(:starf_berry, 100, GameData::Types::PSYCHIC)

      register(:figy_berry, 80, GameData::Types::BUG)
      register(:tanga_berry, 80, GameData::Types::BUG)
      register(:cornn_berry, 90, GameData::Types::BUG)
      register(:enigma_berry, 100, GameData::Types::BUG)

      register(:wiki_berry, 80, GameData::Types::ROCK)
      register(:charti_berry, 80, GameData::Types::ROCK)
      register(:magost_berry, 90, GameData::Types::ROCK)
      register(:micle_berry, 100, GameData::Types::ROCK)

      register(:mago_berry, 80, GameData::Types::GHOST)
      register(:kasib_berry, 80, GameData::Types::GHOST)
      register(:rabuta_berry, 90, GameData::Types::GHOST)
      register(:custap_berry, 100, GameData::Types::GHOST)

      register(:aguav_berry, 80, GameData::Types::DRAGON)
      register(:haban_berry, 80, GameData::Types::DRAGON)
      register(:nomel_berry, 90, GameData::Types::DRAGON)
      register(:jaboca_berry, 100, GameData::Types::DRAGON)

      register(:iapapa_berry, 80, GameData::Types::DARK)
      register(:colbur_berry, 80, GameData::Types::DARK)
      register(:spelon_berry, 90, GameData::Types::DARK)
      register(:rowap_berry, 100, GameData::Types::DARK)

      register(:razz_berry, 80, GameData::Types::STEEL)
      register(:babiri_berry, 80, GameData::Types::STEEL)
      register(:pamtre_berry, 90, GameData::Types::STEEL)

      register(:roseli_berry, 80, GameData::Types::FAIRY)
      register(:kee_berry, 100, GameData::Types::FAIRY)

      register(:maranga_berry, 100, GameData::Types::DARK)
    end
    Move.register(:s_natural_gift, NaturalGift)
  end
end
