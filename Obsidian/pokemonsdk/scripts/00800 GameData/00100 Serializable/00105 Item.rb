module GameData
  # Item Data structure
  # @author Nuri Yuri
  class Item < Base
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
      # Data of the items
      @data = []

      # Get an Item by its ID or DB Symbol
      # @param id [Integer, Symbol] ID of the move in database
      # @return [GameData::Item]
      def [](id)
        id = get_id(id) if id.is_a?(Symbol)
        id = 0 unless id.is_a?(Integer) && id_valid?(id)
        return @data[id]
      end

      # Safely return the db_symbol of an item
      # @param id [Integer] id of the item in the database
      # @return [Symbol]
      def db_symbol(id)
        return (@data[id].db_symbol || :__undef__) if id_valid?(id)
        return :__undef__
      end

      # Get id using symbol
      # @param symbol [Symbol]
      # @return [Integer]
      def get_id(symbol)
        return 0 if symbol == :__undef__

        data = @data.index { |item| item.db_symbol == symbol }
        data || 0
      end

      # Tell if the item id is valid
      # @param id [Integer]
      # @return [Boolean]
      def id_valid?(id)
        return id.between?(1, LAST_ID)
      end

      # Load the items
      def load
        @data = load_data('Data/PSDK/ItemData.rxdata').freeze
        @data.each_with_index { |item, index| item&.id = index }
        GameData::Item.const_set(:LAST_ID, @data.size - 1)
      end

      # Return all the item
      # @return [Array<GameData::Item>]
      def all
        return @data
      end

      # Convert a collection to symbolized collection
      # @param collection [Enumerable]
      # @param keys [Boolean] if hash keys are converted
      # @param values [Boolean] if hash values are converted
      # @return [Enumerable] the collection
      def convert_to_symbols(collection, keys: false, values: false)
        if collection.is_a?(Hash)
          new_collection = {}
          collection.each do |key, value|
            key = db_symbol(key) if keys && key.is_a?(Integer)
            if value.is_a?(Enumerable)
              value = convert_to_symbols(value, keys: keys, values: values)
            elsif values && value.is_a?(Integer)
              value = db_symbol(value)
            end
            new_collection[key] = value
          end
          collection = new_collection
        else
          collection.each_with_index do |value, index|
            if value.is_a?(Enumerable)
              collection[index] = convert_to_symbols(value, keys: keys, values: values)
            elsif value.is_a?(Integer)
              collection[index] = db_symbol(value)
            end
          end
        end
        collection
      end
    end
  end
end
