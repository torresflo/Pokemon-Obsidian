module PFM
  # Player PC storage
  #
  # The main object is stored in $storage and PFM.game_state.storage
  # @author Nuri Yuri
  class Storage
    # Maximum amount of box
    MAX_BOXES = 15
    # Maximum amount of battle box
    MAX_BATTLE_BOX = 16
    # Size of a box
    BOX_SIZE = 30
    # Number of box theme (background : Graphics/PC/f_id, title : Graphics/PC/title_id
    NB_THEMES = 32
    # Tell if the Pokemon gets healed & cured when stored
    HEAL_AND_CURE_POKEMON = true
    # The party of the other actor (friend)
    # @return [Array<PFM::Pokemon>]
    attr_accessor :other_party
    # The id of the current box
    # @return [Integer]
    attr_accessor :current_box
    # The id of the current battle box
    # @return [Integer]
    attr_accessor :current_battle_box
    # The Let's Go Follower
    # @return [PFM::Pokemon]
    attr_accessor :lets_go_follower
    # Get the game state responsive of the whole game state
    # @return [PFM::GameState]
    attr_accessor :game_state
    # Get the battle boxes
    # @return [Array<BattleBox>]
    attr_accessor :battle_boxes
    # Create a new storage
    # @param game_state [PFM::GameState] variable responsive of containing the whole game state for easier access
    def initialize(game_state)
      self.game_state = game_state
      # @type [Array<Box>]
      @boxes = Array.new(MAX_BOXES) { |index| Box.new(BOX_SIZE, send(*box_name_init(index)), index + 1) }
      @battle_boxes = Array.new(MAX_BATTLE_BOX) { |index| BattleBox.new("##{index + 1}") }
      @current_box = 0
      @current_battle_box = 0
      update_event_variables
      @other_party = []
    end

    # Auto convert the data to the new format
    def auto_convert
      if @names
        @boxes.map!.with_index { |box, index| Box.new(0, @names[index], @themes[index], box) }
        remove_instance_variable(:@names)
        remove_instance_variable(:@themes)
      end
      @battle_boxes ||= Array.new(MAX_BATTLE_BOX) { |index| BattleBox.new("##{index + 1}") }
      @current_battle_box ||= 0
    end

    # Store a pokemon to the PC
    # @param pokemon [PFM::Pokemon] the Pokemon to store
    # @return [Boolean] if the Pokemon has been stored
    def store(pokemon)
      return true if store_in_current_box(pokemon)
      return false unless switch_to_box_with_space

      return store_in_current_box(pokemon)
    end

    # Get the current box object
    # @note Any modification will be ignored
    # @return [PFM::Storage::Box]
    def current_box_object
      return @boxes[current_box % @boxes.size].clone
    end

    # Retrieve a box content
    # @param index [Integer] the index of the box
    # @return [Array<PFM::Pokemon, nil>]
    def get_box_content(index)
      return @boxes[index % @boxes.size].content
    end
    alias get_box get_box_content

    # Return a box name
    # @param index [Integer] the index of the box
    # @return [String]
    def get_box_name(index)
      return @boxes[index % @boxes.size].name
    end

    # Change the name of a box
    # @param index [Integer] the index of the box
    # @param name [String] the new name
    def set_box_name(index, name)
      @boxes[index % @boxes.size].name = name.to_s
    end

    # Get the name of a box (initialize)
    # @param index [Integer] the index of the box
    def box_name_init(index)
      return [:text_get, 16, index]
    end

    # Get a box theme
    # @param index [Integer] the index of the box
    # @return [Integer] the id of the box theme
    def get_box_theme(index)
      return @boxes[index % @boxes.size].theme
    end

    # Change the theme of a box
    # @param index [Integer] the index of the box
    # @param theme [Integer] the id of the box theme
    def set_box_theme(index, theme)
      @boxes[index % @boxes.size].theme = theme.to_i
    end

    # Remove a Pokemon in the current box and return what whas removed at the index
    # @param index [Integer] index of the Pokemon in the current box
    # @return [PFM::Pokemon, nil] the pokemon removed
    def remove_pokemon_at(index)
      pokemon = @boxes[@current_box].content[index]
      @boxes[@current_box].content[index] = nil
      return pokemon
    end
    alias remove remove_pokemon_at

    # Is the slot "index" containing a Pokemon ?
    # @param index [Integer] index of the entity in the current box
    # @return [Boolean]
    def slot_contain_pokemon?(index)
      return @boxes[@current_box].content[index].class == ::PFM::Pokemon
    end

    # Return the Pokemon at an index in the current box
    # @param index [Integer] index of the Pokemon in the current box
    # @return [PFM::Pokemon, nil]
    def info(index)
      return @boxes[@current_box].content[index]
    end

    # Store a Pokemon at a specific index in the current box
    # @param pokemon [PFM::Pokemon] the Pokemon to store
    # @param index [Integer] index of the Pokemon in the current box
    # @note The pokemon is healed when stored
    def store_pokemon_at(pokemon, index)
      @boxes[@current_box].content[index] = pokemon
      return unless HEAL_AND_CURE_POKEMON

      pokemon.cure
      pokemon.hp = pokemon.max_hp
    end

    # Return the amount of box in the storage
    # @return [Integer]
    def box_count
      return @boxes.size
    end
    alias max_box box_count

    # Check if there's a Pokemon alive in the box (egg or not)
    # @return [Boolean]
    def any_pokemon_alive?
      return @boxes.any? do |box|
        next box.content.any? { |pokemon| pokemon && !pokemon.dead? }
      end || @battle_boxes.any? do |box|
        next box.content.any? { |pokemon| pokemon && !pokemon.dead? }
      end
    end
    alias any_pokemon_alive any_pokemon_alive?

    # Count the number of Pokemon available in the box
    # @param include_dead [Boolean] if the counter include the "dead" Pokemon
    # @return [Integer]
    def count_pokemon(include_dead = true)
      return @boxes.sum do |box|
        box.content.count { |pokemon| pokemon && (include_dead || !pokemon.dead?) }
      end
    end

    # Yield a block on each Pokemon of storage
    # @yieldparam pokemon [PFM::Pokemon]
    def each_pokemon
      @boxes.each do |box|
        box.content.each do |pokemon|
          yield(pokemon) if pokemon
        end
      end
    end

    # Yield a block on each Pokemon of storage and check if any answers to the block
    # @yieldparam pokemon [PFM::Pokemon]
    # @return [Boolean]
    def any_pokemon?
      @boxes.any? do |box|
        box.content.any? do |pokemon|
          yield(pokemon) if pokemon
        end
      end
    end

    # Delete a box
    # @param index [Integer] index of the box to delete
    def delete_box(index)
      @boxes.delete_at(index)
    end

    # Add a new box
    # @param name [String] name of the new box
    def add_box(name)
      @boxes.push(Box.new(BOX_SIZE, name, 1))
    end

    private

    # Store a pokemon in the current box
    # @param pokemon [PFM::Pokemon] the Pokemon to store
    # @return [Boolean] if the Pokemon has been stored
    def store_in_current_box(pokemon)
      return false unless (position = @boxes[@current_box].content.index(nil))

      store_pokemon_at(pokemon, position)
      return true
    end

    # Find a box with space and change @current_box if found
    # @return [Boolean] if a box with space could be found
    def switch_to_box_with_space
      unless (box_index = @boxes.find_index { |box| box.content.include?(nil) })
        add_box('')
        return false unless (box_index = @boxes.find_index { |box| box.content.include?(nil) })
      end

      @current_box = box_index
      update_event_variables
      return true
    end

    def update_event_variables
      game_state.game_variables[gv_current_box] = @current_box
      game_state&.game_map&.need_refresh = true
    end

    # Get the ID of the current box variable
    # @return [Integer]
    def gv_current_box
      return Yuki::Var::Boxes_Current
    end

    class << self
      # Get the box size
      # @return [Integer]
      def box_size
        BOX_SIZE
      end
    end
  end

  class GameState
    # The PC storage of the player
    # @return [PFM::Storage]
    attr_accessor :storage

    on_player_initialize(:storage) { @storage = PFM.storage_class.new(self) }
    on_expand_global_variables(:storage) do
      # Variable containing the Pokemon Storage System and other parties
      $storage = @storage
      @storage.game_state = self
      @storage.auto_convert
    end
  end
end

PFM.storage_class = PFM::Storage
