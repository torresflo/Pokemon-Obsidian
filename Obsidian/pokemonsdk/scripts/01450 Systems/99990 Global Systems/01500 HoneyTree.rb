module PFM
  module HoneyTree
    # Maximum number of honney trees
    COUNT = 21
    # List of probability for each mon_index
    MON_INDEXES = [0...40, 40...60, 60...80, 80...90, 90...95, 95...100]
    # Probablity to get the last mon_index on the same tree
    LAST_MON_INDEX_CHANCES = 90
    # 2D List of shakes value (column -> chance -> nb_shakes)
    SHAKES_NUMBERS = [
      [],
      [0...20, 20...79, 79...99, 99...100],
      [0...1, 1...21, 21...96, 96...100],
      [0...1, 1...2, 2...7, 7...100]
    ]
    # List of chance to get a specific column if the Tree is a Munchlax tree or not
    COLUMN_INDEXES = {
      false => [0...10, 10...80, 80...100], # Normal
      true => [0...9, 9...29, 29...99, 99...100] # Munchlax
    }
    # Time to wait before being able to fight a Pokemon (in seconds)
    WAIT_TO_BATTLE = 21540
    # Time when the Pokemon leave the tree
    LEAVE_TREE_TIME = 86340
    # List of Pokemon / Column
    POKEMON_LISTS = [
      [], # 0 should be empty
      %i[combee wurmple burmy cherubi aipom aipom], # 1
      %i[burmy cherubi combee aipom aipom heracross], # 2
      %i[munchlax munchlax munchlax munchlax munchlax munchlax]
    ]
    # Level range of the battles
    LEVEL_RANGE = 5..15

    module_function

    # Return the honney tree info
    # @param id [Integer] ID of the tree
    # @return [Hash{ Symbol => Integer}]
    def get(id)
      log_error("Honney tree #{id} should not be read, max_id = #{COUNT - 1}") unless id.between?(0, COUNT - 1)
      return PFM.game_state.honey_trees[id] ||= { column: 0, sakes: 0, mon_index: 0 }
    end

    # Tell if a tree has a Pokemon in it
    # @param id [Integer] ID of the tree
    # @return [Boolean]
    def has_pokemon?(id)
      get(id)[:column] != 0 && (Graphics.current_time - get(id)[:slather_time]) < LEAVE_TREE_TIME
    end

    # Tell if the tree is ready to battle
    # @param id [Integer] ID of the tree
    # @return [Boolean]
    def can_battle?(id)
      has_pokemon?(id) && (Graphics.current_time - get(id)[:slather_time]) > WAIT_TO_BATTLE
    end

    # Slather a tree
    # @param id [Integer] ID of the tree
    def slather(id)
      column = column(id)
      tree = get(id)
      tree[:column] = column
      tree[:mon_index] = mon_index(id)
      tree[:sakes] = shakes(column)
      tree[:slather_time] = Graphics.current_time
    end

    # Return the ID of the last tree
    # @return [Integer]
    def last_tree_id
      return PFM.game_state.user_data[:last_honey_tree] || -1
    end

    # Set the ID of the last tree
    # @param id [Integer] ID of the tree
    def last_tree_id=(id)
      PFM.game_state.user_data[:last_honey_tree] = id
    end

    # Return the last index of the choosen mon in the table
    # @return [Integer]
    def last_mon_index
      PFM.game_state.user_data[:last_honey_mon_index] || 0
    end

    # Set the ID of the last choosen mon in the table
    # @param index [Integer]
    def last_mon_index=(index)
      PFM.game_state.user_data[:last_honey_mon_index] = index
    end

    # Tell if the tree is a munchlax tree or not
    # @param id [Integer] ID of the tree
    # @return [Boolean]
    def munchlax?(id)
      tid = $trainer.id
      return ((tid & 0xFF) % COUNT) == 0 ||
             ((tid >> 8 & 0xFF) % COUNT) == 0 ||
             ((tid >> 16 & 0xFF) % COUNT) == 0 ||
             ((tid >> 24 & 0xFF) % COUNT) == 0
    end

    class << self
      private

      # Get the new column index
      # @param id [Integer] ID of the tree
      # @return [Integer]
      def column(id)
        rng_val = rand(100)
        return COLUMN_INDEXES[munchlax?(id)].index { |cell| cell.include?(rng_val) } || 0
      end

      # Return the index of the current mon
      # @param id [Integer] ID of the tree
      # @return [Integer]
      def mon_index(id)
        if id == last_tree_id
          return last_mon_index if rand(100) < LAST_MON_INDEX_CHANCES
        end
        rng_val = rand(100)
        return MON_INDEXES.index { |cell| cell.include?(rng_val) } || 0
      end

      # Return the number of shakes
      # @param column [Integer] column where to get the shake value
      # @return [Integer]
      def shakes(column)
        rng_val = rand(100)
        return SHAKES_NUMBERS[column].index { |cell| cell.include?(rng_val) } || 0
      end
    end
  end

  class GameState
    # Access to the honey tree information
    # @return [Array<Hash{ Symbol => Integer}>]
    attr_reader :honey_trees
    on_player_initialize(:honey_trees) { @honey_trees = [] }
    on_expand_global_variables(:honey_trees) { @honey_trees ||= [] }
  end
end

# Store the honey tree related messages
Util::SystemMessage::MESSAGES[:honey_tree_slather] = proc { 'Do you want to slather this tree with honey?' }
Util::SystemMessage::MESSAGES[:honey_tree_sweet_scent] = proc { 'There is a sweet scent in the air...' }
Util::SystemMessage::MESSAGES[:honey_tree_slathered] = proc { 'The bark is slathered with Honey...' }

class Interpreter
  # Function calling the honey tree event
  # @param id [Integer] ID of the honey tree
  def honey_tree_event(id)
    if PFM::HoneyTree.has_pokemon?(id) # There's a Pokemon
      show_message(:honey_tree_slathered)
      if PFM::HoneyTree.can_battle?(id)
        honey_data = PFM::HoneyTree.get(id)
        pokemon_id = PFM::HoneyTree::POKEMON_LISTS[honey_data[:column]][honey_data[:mon_index]]
        honey_data[:column] = 0 # Reset
        $wild_battle.start_battle(pokemon_id, rand(PFM::HoneyTree::LEVEL_RANGE))
      else
        honey_tree_slather_event(id)
      end
    else
      show_message(:honey_tree_sweet_scent)
      honey_tree_slather_event(id)
    end
  end

  private

  # Function that asks if you want to slaghter
  # @param id [Integer] ID of the honey tree
  def honey_tree_slather_event(id)
    return unless $bag.contain_item?(:honey)

    if yes_no_choice(load_message(:honey_tree_slather))
      $bag.drop_item(:honey, 1)
      PFM::HoneyTree.slather(id)
    end
  end
end
