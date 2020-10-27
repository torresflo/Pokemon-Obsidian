module GamePlay
  class PokemonStorage < BaseCleanUpdate
    # List of keys supported by the base UI depending on the mode
    BASE_UI_KEYS = [
      regular = %i[A X Y B], # mode = :pokemon
      regular, # mode = :item
      %i[A L R B], # mode = :battle
      regular, # in multi selection
      regular, # in single selection
      regular, # about to swap
      %i[A LEFT RIGHT B], # On the box attempting to change
      regular # When making a choice
    ]
    # List of texts shown by the base UI depending on the mode
    BASE_UI_TEXTS = [
      regular = [': action', nil, ': details', ': quit'], # mode = :pokemon
      regular, # mode = :item
      [': action', ': prev', ': next', ': quit'], # mode = :battle
      [': select', ': move', ': details', ': clear'], # in multi selection
      [': select', nil, ': details', ': clear'], # in single selection
      [': swap', ': swap', ': details', ': clear'], # about to swap
      [': options', ': prev', ': next', ': quit'], # On the box attempting to change
      [nil, nil, nil, ': cancel'] # When making a choice
    ]
    # Hash describing which mode to choose in the base UI when we're in detailed mode
    MODE_TO_BASE_UI_MODE = { pokemon: 0, item: 1, battle: 2 }
    # Create a new Storage Scene
    # @param storage [PFM::Storage] the current storage object
    # @param party [Array<PFM::Pokemon>]
    def initialize(storage = $storage, party = $actors)
      super()
      @storage = storage
      @party = party
      @index = storage.current_box
      @battle_index = 0
      @mouse_actions = BASE_UI_KEYS.map { |arr| arr.map { |v| AIU_KEY2METHOD[v] || :action_b } }
      @moving_pokemon = false
      Mouse.wheel = 0
    end

    def update_graphics
      @composition.update
      @base_ui&.update_background_animation
    end

    private

    def create_graphics
      create_viewport
      create_base_ui
      create_composition
    end

    def create_composition
      mode = $user_data.dig(:storage, :mode) || :pokemon
      selection_mode = $user_data.dig(:storage, :selection_mode) || :detailed
      @composition = UI::Storage::Composition.new(@viewport, mode, selection_mode)
      @composition.storage = @storage
      @composition.party = @party
      @mode_handler = @composition.mode_handler
      @summary = @composition.summary
      @cursor = @composition.cursor_handler
      @selection = @composition.selection_handler
      update_summary
    end

    def create_base_ui
      @base_ui = UI::GenericBaseMultiMode.new(@viewport, base_ui_texts, BASE_UI_KEYS)
    end

    # Get all the base UI texts
    # @return [Array<Array<String>>]
    def base_ui_texts
      BASE_UI_TEXTS.map { |arr| arr.map { |v| get_text(v) } }
    end
  end
end
