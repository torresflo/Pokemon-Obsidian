module GamePlay
  # Class that shows the Pokedex
  class Dex < BaseCleanUpdate
    # Text format for the name
    NAME_FORMAT = '%03d - %s'
    # Array of actions to do according to the pressed button
    ACTIONS = %i[action_A action_X action_Y action_B]
    # Include UI classes
    include UI
    # Create a new Pokedex interface
    # @param page_id [PFM::Pokemon, Integer, false] id of the page to show
    def initialize(page_id = false)
      # We call initialize from GamePlay::Base without arguments to take the default
      super()

      # Pokemon used to generate the list sprites (icon & name)
      @pokemonlist = PFM::Pokemon.new(0, 1)
      # Information telling in which direction (in x) the arrow goes
      @arrow_direction = 1
      # Current state
      @state = page_id ? 1 : 0
      # Current page id
      @page_id = page_id.is_a?(PFM::Pokemon) ? page_id.id : page_id
      @pkmn = page_id.is_a?(PFM::Pokemon) ? page_id.dup : nil
      # Generation of the Pokemon we can see (& adjust page id)
      generate_selected_pokemon_array(page_id)
      # Generation of the Pokemon object used to show the Pokemon info
      generate_pokemon_object
      # We reset the mousewell to prevent issue with scrolling
      Mouse.wheel = 0
    end

    # Update the UI inputs
    def update_inputs
      return action_A if Input.trigger?(:A)
      return action_X if Input.trigger?(:X)
      return action_Y if Input.trigger?(:Y)
      return action_B if Input.trigger?(:B)
      if @state == 0 # Liste
        max_index = @selected_pokemons.size - 1
        if index_changed(:@index, :UP, :DOWN, max_index)
          update_index
        elsif index_changed!(:@index, :LEFT, :RIGHT, max_index)
          9.times { index_changed!(:@index, :LEFT, :RIGHT, max_index) }
          update_index
        elsif Mouse.wheel != 0
          @index = (@index - Mouse.wheel) % (max_index + 1)
          Mouse.wheel = 0
          update_index
        end
      elsif @state == 1 # Description
        max_index = @selected_pokemons.size - 1
        update_index_descr if index_changed(:@index, :UP, :DOWN, max_index)
      elsif @state == 2
        @pokemon_worldmap.update
      end
    end

    # Update the mouse interaction with the ctrl buttons
    # @param _moved [Boolean] if the mouse moved during the frame
    def update_mouse(_moved = false)
      update_mouse_ctrl_buttons(@ctrl, ACTIONS)
    end

    private

    # Update the index when changed
    def update_index
      @pokemon.id = @selected_pokemons[@index]
      @pokeface.data = @pokemon
      update_list(true)
    end

    def update_index_descr
      @pokemon.id = @selected_pokemons[@index]
      @pokeface.data = @pokemon
      change_state(1)
    end

    # Action triggered when A is pressed
    def action_A
      return $game_system.se_play($data_system.buzzer_se) if @page_id
      $game_system.se_play($data_system.decision_se)
      change_state(@state + 1) if @state < 2
    end

    # Action triggered when B is pressed
    def action_B
      $game_system.se_play($data_system.decision_se)
      return @running = false if @state == 0 || @page_id
      change_state(@state - 1) if @state > 0
    end

    # Action triggered when X is pressed
    def action_X
      @pokemon_worldmap.on_toggle_zoom if @state == 2
      return if @state > 1
      return $game_system.se_play($data_system.buzzer_se) if @page_id
      return $game_system.se_play($data_system.buzzer_se) # Non programme
    end

    # Action triggered when Y is pressed
    def action_Y
      @pokemon_worldmap.on_next_worldmap if @state == 2
      return if @state > 1
      return $game_system.se_play($data_system.buzzer_se) if @state == 0
      $game_system.cry_play(@pokemon.id) if @state == 1
    end

    # Change the state of the Interface
    # @param state [Integer] the id of the state
    def change_state(state)
      @state = state
      @base_ui.mode = state
      @frame.set_bitmap(state == 1 ? 'frameinfos' : 'frame', :pokedex)
      @pokeface.data = @pokemon if (@pokeface.visible = state != 2)
      # In show pokemon info mode, those sprites doesn't exist
      if @arrow
        @arrow.visible = @seen_got.visible = state == 0
        @pokemon_worldmap.set_pokemon(@pokemon) if (@pokemon_worldmap.visible = state == 2)
        update_list(state == 0)
      end
      @pokemon_info.visible = @pokemon_descr.visible = state == 1
      if @pokemon_descr.visible
        if $pokedex.pokemon_caught?(@pokemon.id)
          @pokemon_descr.multiline_text = ::GameData::Pokemon[@pokemon.id].descr
        else
          @pokemon_descr.multiline_text = ''
        end
        @pokemon_info.data = @pokemon
      end
    end

    # Update the button list
    # @param visible [Boolean]
    def update_list(visible)
      @scrollbar.visible = @scrollbut.visible = visible
      @scrollbut.y = 41 + 150 * @index / (@selected_pokemons.size - 1) if @selected_pokemons.size > 1
      base_index = calc_base_index
      @list.each_with_index do |el, i|
        next unless (el.visible = visible)
        pos = base_index + i
        id = @selected_pokemons[pos]
        next(el.visible = false) unless id && pos >= 0
        @arrow.y = el.y + 11 if (el.selected = (pos == @index))
        @pokemonlist.id = id
        el.data = @pokemonlist
      end
    end

    # Calculate the base index of the list
    # @return [Integer]
    def calc_base_index
      return -1 if @selected_pokemons.size < 5
      if @index >= 2
        return @index - 2
      elsif @index < 2
        return -1
      end
    end

    # Generate the selected_pokemon array
    # @param page_id [Integer, false] see initialize
    def generate_selected_pokemon_array(page_id)
      if $pokedex.national?
        @selected_pokemons = []
        1.step(GameData::Pokemon.all.size - 1) do |i|
          @selected_pokemons << i if $pokedex.pokemon_seen?(i)
        end
      else
        selected_pokemons = []
        1.step(GameData::Pokemon.all.size - 1) do |i|
          selected_pokemons << i if $pokedex.pokemon_seen?(i) && GameData::Pokemon[i].id_bis > 0
        end
        selected_pokemons.sort! { |a, b| GameData::Pokemon[a].id_bis <=> GameData::Pokemon[b].id_bis }
        @selected_pokemons = selected_pokemons
      end
      @selected_pokemons.compact!
      @selected_pokemons << 0 if @selected_pokemons.empty?
      # Index ajustment
      if page_id
        @index = @selected_pokemons.index(page_id)
        unless @index
          @selected_pokemons << page_id
          @index = @selected_pokemons.size - 1
        end
        # @index -= 1
      else
        @index = 0
      end
    end

    # Generate the Pokemon Object
    def generate_pokemon_object
      @pokemon = @pkmn ||= PFM::Pokemon.generate_from_hash(id: @selected_pokemons[@index].to_i, level: 1, no_shiny: true)
      @pokemon.instance_eval do
        # Return the formated name for Pokedex
        # @return [String]
        def pokedex_name
          id_value = $pokedex.national? ? id : GameData::Pokemon[id].id_bis
          format(GamePlay::Dex::NAME_FORMAT, id_value, name)
        end

        # Return the formated Specie for Pokedex
        # @return [String]
        def pokedex_species
          GameData::Pokemon[id].species
        end

        # Return the formated weight for Pokedex
        # @return [String]
        def pokedex_weight
          # @type [String]
          text = ext_text(9000, 70)
          using_retard_unit = !text.downcase.end_with?('kg')
          format(text, using_retard_unit ? (weight * 2.20462).ceil(2) : weight)
        end

        # Return the formated height for Pokedex
        # @return [String]
        def pokedex_height
          # @type [String]
          text = ext_text(9000, 71)
          using_retard_unit = !text.downcase.end_with?('m')
          if using_retard_unit
            inches = (height * 39.3701).to_i
            feet = inches / 12
            inches -= feet * 12
            format(text, feet, inches)
          else
            return format(text, height)
          end
        end
      end
    end

    # Dispose the interface
    def dispose
      super
      # @viewport.dispose
    end
  end
end
