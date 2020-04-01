module GameData
  # Item Data structure
  # @author Nuri Yuri
  class Item < Base
    # Default icon name
    NO_ICON = 'return'
    # HM/TM text
    HM_TM_TEXT = '%s %s'
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
    class << self
      # Data of the items
      @data = []

      # Safely return the name of an item
      # @param id [Integer, Symbol] id of the item in the database
      # @return [String]
      def name(id)
        id = get_id(id) if id.is_a?(Symbol)
        return text_get(12, id) if id_valid?(id)
        return text_get(12, 0)
      end

      # Safely return the exact name of an item
      # @param id [Integer, Symbol] id of the item in the database
      # @return [String]
      def exact_name(id)
        # Process the HM/TM name
        if (data = misc_data(id)) && (data.ct_id || data.cs_id)
          return format(HM_TM_TEXT, name(id), Skill.name(data.skill_learn.to_i))
        end
        return name(id)
      end

      # Safely return the description of an item
      # @param id [Integer, Symbol] id of the item in the database
      # @return [String]
      def descr(id)
        id = get_id(id) if id.is_a?(Symbol)
        return text_get(13, id) if id_valid?(id)
        return text_get(13, 0)
      end

      # Safely return the icon of an item
      # @param id [Integer, Symbol] id of the item in the database
      # @return [String]
      def icon(id)
        return @data[id].icon if id_valid?(id)
        return NO_ICON
      end

      # Safely return the price of an item
      # @param id [Integer, Symbol] id of the item in the database
      # @return [Integer]
      def price(id)
        id = get_id(id) if id.is_a?(Symbol)
        return @data[id].price if id_valid?(id)
        return 0
      end

      # Safely return the pocket id of an item
      # @param id [Integer, Symbol] id of the item in the database
      # @return [Integer]
      def pocket(id)
        id = get_id(id) if id.is_a?(Symbol)
        return @data[id].socket if id_valid?(id)
        return 0
      end
      alias socket pocket

      # Safely return the battle_usable value of an item
      # @param id [Integer, Symbol] id of the item in the database
      # @return [Boolean]
      def battle_usable?(id)
        id = get_id(id) if id.is_a?(Symbol)
        return @data[id].battle_usable if id_valid?(id)
        return false
      end

      # Safely return the map_usable value of an item
      # @param id [Integer, Symbol] id of the item in the database
      # @return [Boolean]
      def map_usable?(id)
        id = get_id(id) if id.is_a?(Symbol)
        return @data[id].map_usable if id_valid?(id)
        return false
      end

      # Safely return the limited_use value of an item
      # @param id [Integer, Symbol] id of the item in the database
      # @return [Boolean]
      def limited_use?(id)
        id = get_id(id) if id.is_a?(Symbol)
        return @data[id].limited if id_valid?(id)
        return true
      end

      # Safely return the holdable value of an item
      # @param id [Integer, Symbol] id of the item in the database
      # @return [Boolean]
      def holdable?(id)
        id = get_id(id) if id.is_a?(Symbol)
        return @data[id].holdable if id_valid?(id)
        return false
      end

      # Safely return the sort position of an item
      # @param id [Integer, Symbol] id of the item in the database
      # @return [Integer]
      def position(id)
        id = get_id(id) if id.is_a?(Symbol)
        return @data[id].position if id_valid?(id) && @data[id].position
        return 99_999
      end

      # Safely return the heal_data value of an item
      # @param id [Integer, Symbol] id of the item in the database
      # @return [GameData::ItemHeal, nil]
      def heal_data(id)
        id = get_id(id) if id.is_a?(Symbol)
        return @data[id].heal_data if id_valid?(id)
        return nil
      end

      # Safely return the ball_data value of an item
      # @param id [Integer, Symbol] id of the item in the database
      # @return [GameData::BallData, nil]
      def ball_data(id)
        id = get_id(id) if id.is_a?(Symbol)
        return @data[id].ball_data if id_valid?(id)
        return nil
      end

      # Safely return the misc_data of an item
      # @param id [Integer, Symbol] id of the item in the database
      # @return [GameData::ItemMisc, nil]
      def misc_data(id)
        id = get_id(id) if id.is_a?(Symbol)
        return @data[id].misc_data if id_valid?(id)
        return nil
      end

      # Safely return the db_symbol of an item
      # @param id [Integer] id of the item in the database
      # @return [Symbol]
      def db_symbol(id)
        return (@data[id].db_symbol || :__undef__) if id_valid?(id)
        return :__undef__
      end

      # Find an item using symbol
      # @param symbol [Symbol]
      # @return [GameData::Item]
      def find_using_symbol(symbol)
        data = @data.find { |item| item.db_symbol == symbol }
        return @data[0] unless data
        data
      end

      # Get id using symbol
      # @param symbol [Symbol]
      # @return [Integer]
      def get_id(symbol)
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
