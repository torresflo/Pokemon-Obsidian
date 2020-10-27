module GamePlay
  # Load game scene
  class Load < Base
    # @return [String] Default language of the game
    DEFAULT_GAME_LANGUAGE = PSDK_CONFIG.default_language_code
    # @return [Array] List of the languages the player can choose (empty list = no choice)
    LANGUAGE_CHOICE_LIST = PSDK_CONFIG.choosable_language_code
    # @return [Array] List of the language name when the player can choose
    LANGUAGE_CHOICE_NAME = PSDK_CONFIG.choosable_language_texts
    # Number of save allowed (set Float::INFINITY to have infinite saves, set 1 if you want only one save)
    MAXIMUM_SAVE = PSDK_CONFIG.maximum_saves
    # Constant telling the Viewport.oy property doesn't work with Window because of a LiteRGSS bug
    WINDOW_VIEWPORT_INCOMPATIBILITY = false
    # Create a new GamePlay::Load scene
    # @param delete_game [Boolean] if we should delete the save state
    def initialize(delete_game = false)
      super()
      GameData::Text.load
      @running = true
      @index = 0
      @delete_game = File.exist?(Save.save_filename) & delete_game & (MAXIMUM_SAVE <= 1)
      if @delete_game
        $pokemon_party = PFM::Pokemon_Party.new(false, @pokemon_party.options.language)
        $pokemon_party.expand_global_var
      end
    end

    # Main process, this scene is particular because it's aimed to run when Scene_Title still exists so we redefine main
    def main
      create_graphics
      curr_scene = $scene
      check_up
      while @running && curr_scene == $scene
        Graphics.update
        update
      end
      dispose
      # Unload title related pictures
      RPG::Cache.load_title(true)
      RPG::Cache.load_interface(true)
      ::Scheduler.start(:on_scene_switch, ::Scene_Title) if !@running && $scene.is_a?(Scene_Map)
    end

    def update
      return @message_window.update if @delete_game
      if index_changed(:@index, :UP, :DOWN, @max_index)
        refresh
        $game_system.se_play($data_system.cursor_se)
      elsif Input.trigger?(:A) || (debug? && PSDK_CONFIG.skip_title_in_debug)
        action
      elsif Mouse.trigger?(:left)
        mouse_action
      elsif Input.trigger?(:B) && $scene.class == ::Scene_Title
        @running = false
      end
    end

    # Create the save related graphics
    def create_graphics
      create_viewport
      @all_window = UI::SpriteStack.new(@viewport)
      create_background
      create_windows
      @all_window.each { |window| window.visible = false } if @delete_game
      @max_index = @all_window.size - 1
      Graphics.sort_z
      refresh
    end

    # Create the Save Scene viewport
    def create_viewport
      @viewport = Viewport.create(:main, 1)
    end

    # Refresh the window opacity & position
    def refresh
      @all_window.each.with_index do |window, i|
        window.opacity = (i == @index ? 255 : 128)
      end
      current_window = @all_window[@index]
      return unless current_window
      last_y = current_window.y + current_window.height + 2
      if last_y > @viewport.rect.height
        oy = @viewport.rect.height - last_y - 48
        if WINDOW_VIEWPORT_INCOMPATIBILITY
          @all_window.move(0, oy)
        else
          @viewport.oy = -oy
          @background_sprite.oy = oy
        end
      elsif WINDOW_VIEWPORT_INCOMPATIBILITY && (last_y = current_window.y - 2) < 0
        @all_window.move(0, -last_y)
      elsif !WINDOW_VIEWPORT_INCOMPATIBILITY
        @background_sprite.oy = @viewport.oy = 0
      end
    end

    private

    # Execute an action when the validation key is pressed
    def action
      Graphics.freeze
      if @all_window[@index].is_a?(UI::SaveWindow)
        Save.save_index = @all_window[@index].index if MAXIMUM_SAVE > 1
        if @all_window[@index].data
          load_game
        else
          Save.save_index -= 1 if MAXIMUM_SAVE > 1
          create_new_party
          $pokemon_party.expand_global_var
          $game_system.se_play($data_system.cursor_se)
          $game_map.update
        end
      else
        return custom_action
      end
      $trainer.redefine_var
      Yuki::FollowMe.set_battle_entry
      $pokemon_party.env.reset_zone
      $scene = Scene_Map.new
      Yuki::TJN.force_update_tone
      @running = false
    end

    # User defined actions
    def custom_action
      # do nothing
    end

    # Perform the mouse actions
    def mouse_action
      @all_window.each.with_index do |window, i|
        next unless window.visible && window.simple_mouse_in?
        @index = i
        refresh
        action
      end
    end

    # Load the current game
    def load_game
      $pokemon_party = @all_window[@index].data
      $pokemon_party.expand_global_var
      $pokemon_party.load_parameters
      $game_system.se_play($data_system.cursor_se)
      $game_map.setup($game_map.map_id)
      $game_player.moveto($game_player.x, $game_player.y) # center
      $game_party.refresh
      $game_system.bgm_play($game_system.playing_bgm)
      $game_system.bgs_play($game_system.playing_bgs)
      $game_map.update
      $game_temp.message_window_showing = false
      $trainer.load_time
      Pathfinding.load
    end

    # Function that create all the window related to save loading
    # @param last_y [Integer] the y coordinate where the first window should be shown
    # @return [Integer] the last expected y coordinate for a window (for monkey patch)
    def create_windows(last_y = 0)
      1.upto(MAXIMUM_SAVE) do |i|
        Save.save_index = i if MAXIMUM_SAVE > 1
        break unless File.exist?(Save.save_filename)
        save = Save.load
        window = UI::SaveWindow.new(@viewport, i, last_y)
        window.data = save
        last_y = window.y + window.height
        @all_window.add_custom_sprite window
      end
      # New Game Window
      window = UI::SaveWindow.new(@viewport, Save.save_index + 1, last_y)
      window.data = false
      last_y = window.y + window.height
      @all_window.add_custom_sprite window
      return last_y
    end

    # Create the background sprite
    def create_background
      @background_sprite = Sprite.new(@viewport)
      @background_sprite.set_bitmap('save_background', :interface)
    end

    # Ask the player if he really wants to delete his game
    def delete_game_question
      Graphics.transition
      # Message break prevention
      Graphics.update while Input.press?(:B)
      scene = $scene
      $scene = self
      message = text_get(25, 18)
      oui = text_get(25, 20)
      non = text_get(25, 21)
      # Delete the game ?
      c = display_message(message, 1, non, oui)
      if c == 1
        message = text_get(25, 19)
        # Really ?
        c = display_message(message, 1, non, oui)
        if c == 1
          # Ok deleted!
          File.delete(@filename)
          message = text_get(25, 17)
          display_message(message)
        end
      end
      $scene = scene
      return @running = false
    end

    # Create a new game and start it
    def create_new_game
      create_new_party
      $pokemon_party.expand_global_var
      $trainer.redefine_var
      $scene = Scene_Map.new
      Yuki::TJN.force_update_tone
      @running = false
    end

    # Creaye a new Pokemon Party object and ask the language if possible
    def create_new_party
      # No language choice => default language
      if LANGUAGE_CHOICE_LIST.empty?
        $pokemon_party = PFM::Pokemon_Party.new(false, DEFAULT_GAME_LANGUAGE)
      else
        @all_window.each { |window| window.visible = false }
        call_scene(Language_Choice)
      end
    end

    # Check if the game states should be deleted or if the player should start a new game
    def check_up
      return delete_game_question if @delete_game
      # Make sure the save index is correct when multi save is allowed
      Save.save_index = 1 if MAXIMUM_SAVE > 1
      return create_new_game unless find_save
      @all_window.each { |window| window.visible = true }
      Graphics.transition
    end

    # Return a save that exists and is loaded
    # @return [PFM::Pokemon_Party, nil]
    def find_save
      @all_window.stack.find { |window| window.is_a?(UI::SaveWindow) && window.data }&.data
    end
  end
end
