module GamePlay
  # Scene displaying the Summary of a Pokemon
  class Summary < BaseCleanUpdate::FrameBalanced
    # @return [Integer] Last state index in this scene
    LAST_STATE = 2
    # Array of Key to press
    KEYS = [
      %i[DOWN LEFT RIGHT B],
      %i[DOWN LEFT RIGHT B],
      %i[A LEFT RIGHT B],
      %i[A LEFT RIGHT B],
      %i[A LEFT RIGHT B],
      %i[A LEFT RIGHT B]
    ]
    # Text base indexes in the file
    TEXT_INDEXES = [
      [112, 113, 114, 115],
      [112, 116, 113, 115],
      [117, 114, 116, 115],
      [118, nil, nil, 13],
      [119, nil, nil, 13],
      [nil, nil, nil, 13]
    ]
    # @return [Integer] Index of the choosen skill of the Pokemon
    attr_accessor :skill_selected
    # Create a new sumarry Interface
    # @param pokemon [PFM::Pokemon] Pokemon currently shown
    # @param mode [Symbol] :view if it's about viewing a Pokemon, :skill if it's about choosing the skill of the Pokemon
    # @param party [Array<PFM::Pokemon>] the party (allowing to switch Pokemon)
    # @param extend_data [PFM::ItemDescriptor::Wrapper, nil] the extend data information when we are in :skill mode
    def initialize(pokemon, mode = :view, party = [pokemon], extend_data = nil)
      super()
      # @type [PFM::Pokemon]
      @pokemon = pokemon
      @mode = mode
      @party = party
      @index = mode == :skill ? 2 : 0
      @party_index = party.index(pokemon).to_i
      @skill_selected = -1
      @skill_index = -1
      @selecting_move = false
      @extend_data = extend_data
    end

    private

    # Create all the UI of the scene & set their default content
    def create_graphics
      create_viewport
      create_base
      create_uis
      create_top_ui
      update_pokemon
    end

    # Create the generic base
    def create_base
      @base_ui = UI::GenericBaseMultiMode.new(@viewport, load_texts, KEYS, ctrl_id_state)
      init_win_text
    end

    # Create the various UI
    def create_uis
      @uis = [
        UI::Summary_Memo.new(@viewport),
        UI::Summary_Stat.new(@viewport),
        UI::Summary_Skills.new(@viewport)
      ]
    end

    # Create the top UI
    def create_top_ui
      @top = UI::Summary_Top.new(@viewport)
    end

    # Initialize the win_text according to the mode
    def init_win_text
      return if @mode != :skill

      if @extend_data
        @base_ui.show_win_text(text_get(23, @extend_data.skill_message_id || 34))
      else
        @base_ui.show_win_text(ext_text(9000, 120))
      end
    end

    # Update the UI visibility according to the index
    def update_ui_visibility
      @uis.each_with_index { |ui, index| ui.visible = index == @index }
      update_ctrl_state
    end

    # Update the Pokemon shown in the UIs
    def update_pokemon
      @uis.each { |ui| ui.data = @pokemon }
      @top.data = @pokemon
      Audio.se_play(@pokemon.cry) unless @pokemon.egg?
      update_ui_visibility
    end

    # Update the control button state
    def update_ctrl_state
      @base_ui.mode = ctrl_id_state
    end

    # Retrieve the ID state of the ctrl button
    # @return [Integer] a number sent to @base_ui.mode to choose the texts to show
    def ctrl_id_state
      case @index
      when 0
        return 0
      when 1
        return 1
      when 2
        return 5 if @mode == :skill
        return 4 if @skill_index >= 0
        return 3 if @selecting_move
      end
      return 2
    end

    # Load all the text for the scene
    # @return [Array<Array<String>>]
    def load_texts
      TEXT_INDEXES.collect do |text_indexes|
        text_indexes.collect { |text_id| text_id && ext_text(9000, text_id) }
      end
    end
  end
end

GamePlay.summary_class = GamePlay::Summary
