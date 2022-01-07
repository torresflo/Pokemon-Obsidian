module GamePlay
  # Main menu UI
  #
  # Rewritten thanks to Jaizu demand
  class Menu < BaseCleanUpdate::FrameBalanced
    include MenuMixin
    # List of action according to the "image_index" to call
    ACTION_LIST = %i[open_dex open_party open_bag open_tcard open_option open_save open_quit]
    # Entering - leaving animation offset
    ENTERING_ANIMATION_OFFSET = 150
    # Entering - leaving animation duration
    ENTERING_ANIMATION_DURATION = 15
    # Create a new menu
    def initialize
      super
      init_conditions
      init_indexes
      @call_skill_process = nil
      @index = $game_temp.last_menu_index
      @index = 0 if @index >= @image_indexes.size
      @max_index = @image_indexes.size - 1
      @quiting = false # Flag allowing to really quit
      @entering = true # Flag telling we're entering
      @counter = 0 # Animation counter
      @in_save = false
      @mbf_type = @mef_type = :noen if $scene.is_a?(Scene_Map)
    end

    # Create all the graphics
    def create_graphics
      create_viewport
      create_background
      create_buttons
      init_entering
    end

    # End of the scene
    def main_end
      super
      $game_temp.last_menu_index = @index
    end

    # Update the input interaction
    # @return [Boolean] if no input was detected
    def update_inputs
      return false if @entering || @quiting
      if index_changed(:@index, :UP, :DOWN, @max_index)
        play_cursor_se
        update_buttons
      elsif Input.trigger?(:A)
        action
      elsif Input.trigger?(:B)
        @running = false
      else
        return true
      end
      return false
    end

    # Update the mouse interaction
    # @param moved [Boolean] if the mouse moved
    # @return [Boolean]
    def update_mouse(moved)
      @buttons.each_with_index do |button, index|
        next unless button.simple_mouse_in?
        if moved
          last_index = @index
          @index = index
          if last_index != index
            update_buttons
            play_cursor_se
          end
        elsif Mouse.trigger?(:LEFT)
          @index = index
          update_buttons
          play_decision_se
          action
        end
        return false
      end
      return true
    end

    # Update the graphics
    def update_graphics
      # Little trick to allow quitting animation ;)
      unless @running || @quiting
        @quiting = true
        @running = true
        @__last_scene.spriteset.visible = true if @__last_scene.is_a?(Scene_Map)
      end
      # Update each animation
      if @entering
        update_entering_animation
      elsif @quiting
        update_quitting_animation
      else
        @buttons.each(&:update)
      end
    end

    # Overload the visible= to allow save to keep the curren background
    # @param value [Boolean]
    def visible=(value)
      if @in_save
        @buttons.each { |button| button.visible = value }
      else
        super(value)
      end
    end

    private

    # Animation played during enter sequence
    def update_entering_animation
      @buttons.each { |button| button.move(-ENTERING_ANIMATION_OFFSET / ENTERING_ANIMATION_DURATION, 0) }
      @background.opacity += 255 / ENTERING_ANIMATION_DURATION
      @counter += 1
      if @counter >= ENTERING_ANIMATION_DURATION
        @counter = 0
        @entering = false
        update_buttons
        @background.opacity = 255
        @__last_scene.spriteset.visible = false if @__last_scene.is_a?(Scene_Map)
      end
    end

    # Animation played during the quit sequence
    def update_quitting_animation
      @buttons.each { |button| button.move(ENTERING_ANIMATION_OFFSET / ENTERING_ANIMATION_DURATION, 0) }
      @background.opacity -= 255 / ENTERING_ANIMATION_DURATION
      @counter += 1
      @running = false if @counter >= ENTERING_ANIMATION_DURATION
    end

    # Create the conditional array telling which scene is enabled
    def init_conditions
      @conditions =
        [
          $game_switches[Yuki::Sw::Pokedex], # Pokedex
          $actors.any?, # Party
          !$bag.locked, # Bag
          true, # Trainer card
          true, # Options
          !$game_system.save_disabled, # Save
          true
        ]
    end

    # Init the image_indexes array
    def init_indexes
      @image_indexes = @conditions.collect.with_index { |condition, index| condition ? index : nil }
      @image_indexes.compact!
    end

    # Create the background image (blur)
    def create_background
      add_disposable @background = UI::BlurScreenshot.new(@__last_scene)
      @background.opacity -= 255 / ENTERING_ANIMATION_DURATION * ENTERING_ANIMATION_DURATION
    end

    # Create the menu buttons
    def create_buttons
      @buttons = Array.new(@image_indexes.size) do |i|
        UI::PSDKMenuButton.new(@viewport, @image_indexes[i], i)
      end
    end

    # Update the menu button states
    def update_buttons
      @buttons.each_with_index { |button, index| button.selected = index == @index }
    end

    # Init the entering animation
    def init_entering
      @buttons.each { |button| button.move(ENTERING_ANIMATION_OFFSET, 0) }
    end

    # Perform the action to do at the current index
    def action
      play_decision_se
      send(ACTION_LIST[@image_indexes[@index]])
    end

    # Open the Dex UI
    def open_dex
      GamePlay.open_dex
    end

    # Open the Party_Menu UI
    def open_party
      GamePlay.open_party_menu do |scene|
        Yuki::FollowMe.update
        @background.update_snapshot
        if scene.call_skill_process
          @call_skill_process = scene.call_skill_process
          @running = false
          Graphics.transition
        end
      end
    end

    # Open the Bag UI
    def open_bag
      GamePlay.open_bag
      Graphics.transition unless @running
    end

    # Open the TCard UI
    def open_tcard
      GamePlay.open_player_information
    end

    # Open the Save UI
    def open_save
      @in_save = true
      call_scene(Save) do |scene|
        @running = false if scene.saved
        Graphics.transition
      end
      @in_save = false
    end

    # Open the Options UI
    def open_option
      GamePlay.open_options do |scene|
        if scene.modified_options.include?(:language)
          @running = false
          Graphics.transition
        end
      end
    end

    # Quit the scene
    def open_quit
      @running = false
    end
  end
end

GamePlay.menu_class = GamePlay::Menu
