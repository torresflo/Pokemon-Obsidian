module GameData
  # Item Data structure
  # @author Nuri Yuri
  class Item < Base
    extend DataSource
    # Default icon name
    NO_ICON = 'return'
    # HM/TM text
    HM_TM_TEXT = '%s %s'
    # List of get item ME
    ItemGetME = %w[Audio/ME/ROSA_ItemObtained.ogg Audio/ME/ROSA_KeyItemObtained.ogg Audio/ME/ROSA_TMObtained.ogg]
    # Name of the item icon in Graphics/Icons/
    # @return [String]
    attr_accessor :icon
    # Price of the item
    # @return [Integer]
    attr_accessor :price
    # Socket id of the item
    # @return [Integer]
    attr_accessor :socket
    # Sort position in the bag, the lesser the position is, the topper it item is shown
    # @return [Integer]
    attr_accessor :position
    # If the item can be used in Battle
    # @return [Boolean]
    attr_accessor :battle_usable
    # If the item can be used in Map
    # @return [Boolean]
    attr_accessor :map_usable
    # If the item has limited uses (can be thrown)
    # @return [Boolean]
    attr_accessor :limited
    # If the item can be held by a Pokemon
    # @return [Boolean]
    attr_accessor :holdable
    # Power of the item when thrown to an other pokemon
    # @return [Integer]
    attr_accessor :fling_power
    # Heal related data of the item
    # @return [GameData::ItemHeal, nil]
    attr_accessor :heal_data
    # Ball related data of the item
    # @return [GameData::BallData, nil]
    attr_accessor :ball_data
    # Miscellaneous data of the item
    # @return [GameData::ItemMisc, nil]
    attr_accessor :misc_data

    # Get the name
    # @return [String]
    def name
      return text_get(12, @id) if Item.id_valid?(@id)

      return text_get(12, 0)
    end

    # Get the "exact" name
    # @return [String]
    def exact_name
      if (data = misc_data) && (data.ct_id || data.cs_id)
        return format(HM_TM_TEXT, name, Skill[data.skill_learn.to_i].name)
      end

      return name
    end

    # Get the plural name
    # @return [String]
    def plural_name
      return ext_text(9001, @id) if Item.id_valid?(@id)

      return ext_text(9001, 0)
    end

    # Get the description
    # @return [String]
    def descr
      return text_get(13, @id) if Item.id_valid?(@id)

      return text_get(13, 0)
    end

    # Get the ME of the item when it's got
    # @return [String]
    def me
      return ItemGetME[2] if socket == 3
      return ItemGetME[1] if socket == 5

      return ItemGetME[0]
    end

    class << self
      # Name of the file containing the data
      def data_filename
        return 'Data/PSDK/ItemData.rxdata'
      end
    end
  end
end
