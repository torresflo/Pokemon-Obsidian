module GameData
  # Data containing all the information about a specific quest
  class Quest < Base
    # If the quest is a primary quest
    # @return [Boolean]
    attr_accessor :primary
    # List of Objectives to complete the quest
    # @return [Array<Objective>]
    attr_accessor :objectives
    # List of Earnings given
    # @return [Array<Earning>]
    attr_accessor :earnings

    # Get the name of the quest
    # @return [String]
    def name
      text_get(45, @id)
    end

    # Get the description of the quest
    # @return [String]
    def descr
      text_get(46, @id)
    end

    # Data containing the specific information about an objective
    class Objective
      # Name of the method that validate the objective in PFM::Quests
      # @return [Symbol]
      attr_accessor :test_method_name
      # Argument for the objective validation method & text format method
      # @return [Array]
      attr_accessor :test_method_args
      # Name of the method that formats the text for the objective list
      # @return [Symbol]
      attr_accessor :text_format_method_name
      # Boolean telling if it's hidden or not by default
      # @return [Boolean]
      attr_accessor :hidden_by_default

      # Create a new objective
      # @param test_method_name [Symbol]
      # @param test_method_args [Array]
      # @param text_format_method_name [Symbol]
      # @param hidden_by_default [Boolean]
      def initialize(test_method_name, test_method_args, text_format_method_name, hidden_by_default = false)
        @test_method_name = test_method_name
        @test_method_args = test_method_args
        @text_format_method_name = text_format_method_name
        @hidden_by_default = hidden_by_default
      end
    end
    # Data containing the specific information about the earning
    class Earning
      # Name of the method called in PFM::Quests when the earning is obtained
      # @return [Symbol]
      attr_accessor :give_method_name
      # Name of the method used to format the text of the earning
      # @return [Symbol]
      attr_accessor :text_format_method_name
      # Argument sent to the give & text format method
      # @return [Array]
      attr_accessor :give_args

      # Create a new earning
      # @param give_method_name [Symbol]
      # @param give_args [Array]
      # @param text_format_method_name [Symbol]
      def initialize(give_method_name, give_args, text_format_method_name)
        @give_method_name = give_method_name
        @give_args = give_args
        @text_format_method_name = text_format_method_name
      end
    end

    # Function that converts the current quest to the new format
    def convert_to_new_format
      return if objectives.is_a?(Array)

      objs = @objectives = []
      old_earnings = @earnings
      earns = @earnings = []
      # Convert speak to
      @speak_to&.each_with_index do |name, index|
        objs << Objective.new(:objective_speak_to, [index, name], :text_speak_to)
      end
      # Convert items
      @items&.each_with_index do |item_id, index|
        amount = @item_amount[index] || 1
        objs << Objective.new(:objective_obtain_item, [item_id, amount], :text_obtain_item)
      end
      # Convert see pokemon
      @see_pokemon&.each do |pokemon_id|
        objs << Objective.new(:objective_see_pokemon, [pokemon_id], :text_see_pokemon)
      end
      # Convert beat pokemon
      @beat_pokemon&.each_with_index do |pokemon_id, index|
        amount = @beat_pokemon_amount[index] || 1
        objs << Objective.new(:objective_beat_pokemon, [pokemon_id, amount], :text_beat_pokemon)
      end
      # Convert catch pokemon
      @catch_pokemon&.each_with_index do |pokemon_id, index|
        amount = @catch_pokemon_amount[index] || 1
        objs << Objective.new(:objective_catch_pokemon, [pokemon_id, amount], :text_catch_pokemon)
      end
      # Convert beat_npc
      @beat_npc&.each_with_index do |name, index|
        amount = @beat_npc_amount[index]
        objs << Objective.new(:objective_beat_npc, [index, name, amount], :text_beat_npc)
      end
      # Convert get egg
      objs << Objective.new(:objective_obtain_egg, [@get_egg_amount], :text_obtain_egg) if @get_egg_amount
      objs << Objective.new(:objective_hatch_egg, [nil, @hatch_egg_amount], :text_hatch_egg) if @hatch_egg_amount
      # Convert earnings
      old_earnings.each do |earning|
        next earns << earning if earning.is_a?(Earning)
        next earns << Earning.new(:earning_money, [earning[:money]], :text_earn_money) if earning[:money]

        earns << Earning.new(:earning_item, [earning[:item], earning[:item_amount]], :text_earn_item)
      end
    end

    class << self
      # All the quests
      # @type [Array<GameData::Quest>]
      @data = []

      # Tell if the quest ID is valid
      # @param id [Integer]
      # @return [Boolean]
      def id_valid?(id)
        return id.between?(0, @data.size - 1)
      end

      # Retrieve a specific quest
      # @param id [Integer]
      # @return [GameData::Quest]
      def [](id)
        return @data[id] if id_valid?(id)

        return @data.first
      end

      # Get all the quests
      # @return [Array<GameData::Quest>]
      def all
        return @data
      end

      # Load the quests
      def load
        # @type [GameData::Quest]
        @data = load_data('Data/PSDK/Quests.rxdata')
        @data.each(&:convert_to_new_format)
        @data.each_with_index do |quest, id|
          quest.id = id
        end
      end
    end
  end
end
