module GameData
  # Class Responsive of encoding data collection to JSON
  class JSONFromDataCollection
    # @return [Array, Object] the data to convert
    attr_accessor :data

    # Create a new converter
    # @param data [Array, Object] thing to convert from or to JSON
    # @param no_symbol_conv [Boolean] tell not to convert ID into symbols
    def initialize(data, no_symbol_conv = false)
      @data = data
      @no_symbol_conv = no_symbol_conv
    end

    # Perform the convert operation
    # @param filename [String] name of the file getting the JSON data
    def convert(filename)
      data = send(*convert_action)
      JSON.dump_default_options[:indent] = "\t"
      JSON.dump_default_options[:space] = ' '
      JSON.dump_default_options[:object_nl] = "\n"
      JSON.dump_default_options[:array_nl] = "\n"
      File.open(filename, 'w') { |f| JSON.dump(data, f) }
    end

    private

    # Return the message to send to convert the data
    # @return [Array, symbol]
    def convert_action
      return convert_array_action if @data.is_a?(Array)
      return convert_object_action
    end

    # Return the message to send to convert the array data
    # @return [Array, symbol]
    def convert_array_action
      first = @data.first
      return :convert_all_pokemon if first.is_a?(Array)
      return :convert_all_item if first.is_a?(GameData::Item)
      return :convert_all_skill if first.is_a?(GameData::Skill)
      return :convert_all_quests if first.is_a?(GameData::Quest)
      return :convert_all_types if first.is_a?(GameData::Type)
      return :convert_all_trainers if first.is_a?(GameData::Trainer)
      return :inspect
    end

    # Return the message to send to convert the data object
    # @return [Array, symbol]
    def convert_object_action
      klass = @data.class
      case klass
      when Pokemon
        return :convert_single_pokemon, @data
      when Item
        return :convert_single_item, @data
      when Skill
        return :convert_single_skill, @data
      when ItemHeal
        return :convert_single_heal_data, @data
      when BallData
        return :convert_single_ball_data, @data
      when ItemMisc
        return :convert_single_misc_data, @data
      else
        return :convert_all_natures if @data == Natures
        return :convert_all_abilities if @data == Abilities
        return :inspect
      end
    end
  end
end
