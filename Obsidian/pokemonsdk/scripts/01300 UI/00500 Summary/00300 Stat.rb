module UI
  # UI part displaying the Stats of a Pokemon in the Summary
  class Summary_Stat < SpriteStack
    # Show the IV ?
    SHOW_IV = true
    # Show the EV ?
    SHOW_EV = true
    # Create a new Stat UI for the summary
    # @param viewport [Viewport]
    def initialize(viewport)
      super(viewport, 0, 0, default_cache: :interface)
      init_sprite
    end

    # Set the Pokemon shown by the UI
    # @param pokemon [PFM::Pokemon]
    def data=(pokemon)
      super
      @nature_text.text = PFM::Text.parse(28, pokemon.nature_id)
      # Load the stat color according to the nature
      nature = pokemon.nature
      1.upto(5) do |i|
        color = nature[i] < 100 ? 23 : 22
        color = 0 if nature[i] == 100
        @stat_name_texts[i - 1].load_color(color)
      end
    end

    private

    def init_sprite
      create_background
      init_stats
      init_ability
      @hp_container = create_hp_bg
      @hp = add_custom_sprite(create_hp_bar) # Copy/Paste from Party_Menu
    end

    def create_background
      push(0, 0, 'summary/stats')
    end

    def init_ability
      ability_text = add_text(13, 138, 100, 16, text_get(33, 142) + ': ')
      @ability_name = add_text(13 + ability_text.real_width, 138, 294, 16, :ability_name, type: SymText, color: 1)
      @ability_descr = add_text(13, 138 + 16, 294, 16, :ability_descr, type: SymMultilineText)
    end

    def create_hp_bg
      add_sprite(11, 128, RPG::Cache.interface('menu_pokemon_hp'), rect: Rect.new(0, 0, 67, 6))
    end

    # Init the stat texts
    def init_stats
      @stat_name_texts = []
      texts = text_file_get(27)
      with_surface(114, 19, 95) do
        # --- Static part ---
        @nature_text = add_line(0, '') # Nature
        add_line(1, texts[15]) # HP
        @stat_name_texts << add_line(2, texts[18]) # Attack
        @stat_name_texts << add_line(3, texts[20]) # Defense
        @stat_name_texts << add_line(4, texts[26]) # Speed
        @stat_name_texts << add_line(5, texts[22]) # Attack Spe
        @stat_name_texts << add_line(6, texts[24]) # Defense Spe
        # --- Data part ---
        add_line(1, :hp_text, 2, type: SymText, color: 1)
        add_line(2, :atk_basis, 2, type: SymText, color: 1)
        add_line(3, :dfe_basis, 2, type: SymText, color: 1)
        add_line(4, :spd_basis, 2, type: SymText, color: 1)
        add_line(5, :ats_basis, 2, type: SymText, color: 1)
        add_line(6, :dfs_basis, 2, type: SymText, color: 1)
      end
      init_ev_iv
    end

    # Create the HP Bar for the pokemon Copy/Paste from Menu_Party
    # @return [UI::Bar]
    def create_hp_bar
      bar = Bar.new(@viewport, 25, 129, RPG::Cache.interface('team/HPBars'), 52, 4, 0, 0, 3)
      # Define the data source of the HP Bar
      bar.data_source = :hp_rate
      return bar
    end

    # Init the ev/iv texts
    def init_ev_iv
      offset = 102
      # --- EV part ---
      if SHOW_EV
        with_surface(114 + offset, 19, 95) do
          add_line(1, :ev_hp_text, type: SymText)
          add_line(2, :ev_atk_text, type: SymText)
          add_line(3, :ev_dfe_text, type: SymText)
          add_line(4, :ev_spd_text, type: SymText)
          add_line(5, :ev_ats_text, type: SymText)
          add_line(6, :ev_dfs_text, type: SymText)
        end
        offset += 44
      end
      # --- IV part ---
      if SHOW_IV
        with_surface(114 + offset, 19, 95) do
          add_line(1, :iv_hp_text, type: SymText)
          add_line(2, :iv_atk_text, type: SymText)
          add_line(3, :iv_dfe_text, type: SymText)
          add_line(4, :iv_spd_text, type: SymText)
          add_line(5, :iv_ats_text, type: SymText)
          add_line(6, :iv_dfs_text, type: SymText)
        end
      end
    end
  end
end
