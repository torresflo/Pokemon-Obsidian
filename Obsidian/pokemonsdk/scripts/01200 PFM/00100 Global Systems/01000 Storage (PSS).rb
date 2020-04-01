module PFM
  # Player PC storage
  #
  # The main object is stored in $storage and $pokemon_party.storage
  # @author Nuri Yuri
  class Storage
    # Maximum amount of box
    MAX_BOXES = 31
    # Number of box theme (background : Graphics/PC/f_id, title : Graphics/PC/title_id
    NB_THEMES = 32
    # The party of the other actor (friend)
    # @return [Array<PFM::Pokemon>]
    attr_accessor :other_party
    # The id of the current box
    # @return [Integer]
    attr_accessor :current_box
    # The Let's Go Follower
    # @return [PFM::Pokemon]
    attr_accessor :lets_go_follower
    # Create a new storage
    def initialize
      @boxes = Array.new(MAX_BOXES) { Array.new(30) }
      @names = Array.new(MAX_BOXES) { |i| text_get(16, i) }
      @themes = 1.upto(MAX_BOXES).to_a
      $game_variables[Yuki::Var::Boxes_Current] = @current_box = 0
      @other_party = []
    end

    # Store a pokemon to the PC
    # @param pokemon [PFM::Pokemon] the Pokemon to store
    # @return [Boolean] if the Pokemon has been stored
    def store(pokemon)
      return true if store_in_current_box(pokemon)
      return false unless switch_to_box_with_space
      return store_in_current_box(pokemon)
    end

    # Retrieve a box content
    # @param id [Integer] the id of the box
    # @return [Array<30 PFM::Pokemon, nil>]
    def get_box(id)
      return @boxes[id]
    end

    # Return a box name
    # @param id [Integer] the id of the box
    # @return [String]
    def get_box_name(id)
      return @names[id]
    end

    # Change the name of a box
    # @param id [Integer] the id of the box
    # @param name [String] the new name
    def set_box_name(id, name)
      @names[id] = name.to_s
    end

    # Get a box theme
    # @param id [Integer] the id of the box
    # @return [Integer] the id of the box theme
    def get_box_theme(id)
      return @themes[id]
    end

    # Change the theme of a box
    # @param id [Integer] the id of the box
    # @param theme [Integer] the id of the box theme
    def set_box_theme(id, theme)
      @themes[id] = theme.to_i
    end

    # Remove a Pokemon in the current box and return what whas removed at the index
    # @param index [Integer] index of the Pokemon in the current box
    # @return [PFM::Pokemon, nil] the pokemon removed
    def remove_pokemon_at(index)
      pokemon = @boxes[@current_box][index]
      @boxes[@current_box][index] = nil
      return pokemon
    end
    alias remove remove_pokemon_at

    # Is the slot "index" containing a Pokemon ?
    # @param index [Integer] index of the entity in the current box
    # @return [Boolean]
    def slot_contain_pokemon?(index)
      return @boxes[@current_box][index].class == ::PFM::Pokemon
    end

    # Return the Pokemon at an index in the current box
    # @param index [Integer] index of the Pokemon in the current box
    # @return [PFM::Pokemon, nil]
    def info(index)
      return @boxes[@current_box][index]
    end

    # Store a Pokemon at a specific index in the current box
    # @param pokemon [PFM::Pokemon] the Pokemon to store
    # @param index [Integer] index of the Pokemon in the current box
    # @note The pokemon is healed when stored
    def store_pokemon_at(pokemon, index)
      @boxes[@current_box][index] = pokemon
      pokemon.cure
      pokemon.hp = pokemon.max_hp
    end

    # Return the amount of box in the storage
    # @return [Integer]
    def max_box
      return @boxes.size
    end

    # Check if there's a Pokemon alive in the box (egg or not)
    # @return [Boolean]
    def any_pokemon_alive
      return @boxes.any? do |box|
        next box.any? { |pokemon| pokemon && !pokemon.dead? }
      end
    end

    # Count the number of Pokemon available in the box
    # @param include_dead [Boolean] if the counter include the "dead" Pokemon
    # @return [Integer]
    def count_pokemon(include_dead = true)
      return @boxes.sum do |box|
        box.count { |pokemon| pokemon && (include_dead || !pokemon.dead?) }
      end
    end

    # Yield a block on each Pokemon of storage
    def each_pokemon
      @boxes.each do |box|
        box.each do |pokemon|
          yield(pokemon) if pokemon
        end
      end
    end

    private

    # Store a pokemon in the current box
    # @param pokemon [PFM::Pokemon] the Pokemon to store
    # @return [Boolean] if the Pokemon has been stored
    def store_in_current_box(pokemon)
      return false unless (position = @boxes[@current_box].index(nil))
      store_pokemon_at(pokemon, position)
      return true
    end

    # Find a box with space and change @current_box if found
    # @return [Boolean] if a box with space could be found
    def switch_to_box_with_space
      return false unless (box_index = @boxes.find_index { |box| box.include?(nil) })
      @current_box = box_index
      $game_variables[Yuki::Var::Boxes_Current] = box_index
      return true
    end
  end

  class Pokemon_Party
    # The PC storage of the player
    # @return [PFM::Storage]
    attr_accessor :storage
    on_player_initialize(:storage) { @storage = PFM::Storage.new }
    on_expand_global_variables(:storage) do
      # Variable containing the Pokemon Storage System and other parties
      $storage = @storage
    end
  end
end
