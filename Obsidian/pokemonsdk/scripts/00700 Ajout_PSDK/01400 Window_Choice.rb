# Display a choice Window
# @author Nuri Yuri
# @deprecated Don't use this otherwise your script will be broken once I removed this !
#   Use Yuki::ChoiceWindow instead.
class Window_Choice < Game_Window
  # Array of choice colors
  # @return [Array<Integer>]
  attr_accessor :colors
  # Current choix (0~choice_max-1)
  # @return [Integer]
  attr_accessor :index
  # Name of the cursor in Graphics/Windowskins/
  CursorSkin = "Cursor"
  # Name of the windowskin in Graphics/Windowskins/
  WindowSkin = "Message"
  # Number of choice shown until a relative display is generated
  MaxChoice = 9
  # Index that tells the system to scroll up or down everychoice (relative display)
  DeltaChoice = (MaxChoice / 2.0).round
  # Create a new Window_Choice with the right parameters
  # @param width [Integer] width of the window
  # @param choices [Array<String>] list of choices
  # @param viewport [Viewport, nil] viewport in which the window is displayed
  def initialize(width, choices, viewport = nil)
    super(viewport)
    @text_viewport = Viewport.create(0, 0, width, MaxChoice * 16)
    @choices = choices
    @colors = Array.new(@choices.size, get_default_color)
    @index = $game_temp ? $game_temp.choice_start - 1 : 0
    @index = 0 if(@index >= choices.size or @index < 0)
    self.width = width
    build_window
    self.cursor_rect.set(-8, 0, 16, 16)
    self.cursorskin = RPG::Cache.windowskin(CursorSkin)
    self.windowskin = RPG::Cache.windowskin(WindowSkin)
    self.active = true
    @cursor_rect.y = @index * 16
    @my = Mouse.y
  end
  # Update the choice, if player hit up or down the choice index changes
  def update
    if(Input.repeat?(:DOWN))
      update_cursor_down
    elsif(Input.repeat?(:UP))
      update_cursor_up
    elsif(@my != Mouse.y || Mouse.wheel != 0)
      update_mouse
    end
    super
  end
  # Return the default text color
  # @return [Integer]
  def get_default_color
    return 0
  end
  # Return the disable text color
  # @return [Integer]
  def get_disable_color
    return 7
  end
  # Update the mouse action
  def update_mouse
    @my = Mouse.y
    if(Mouse.wheel != 0)
      Mouse.wheel > 0 ? update_cursor_up : update_cursor_down
      return Mouse.wheel = 0
    end
    return unless @window.simple_mouse_in?
    @texts.each_with_index do |text, i|
      if text.simple_mouse_in?
        if @index < i
          update_cursor_down while @index < i
        elsif @index > i
          update_cursor_up while @index > i
        end
        break
      end
    end
  end
  # Update the choice display when player hit UP
  def update_cursor_up
    if @index == 0
      (@choices.size - 1).times { update_cursor_down }
      return
    end
    if(@choices.size > MaxChoice)
      if(@index < DeltaChoice or 
          @index > (@choices.size - DeltaChoice))
        @cursor_rect.y -= 16
      else
        @oy -= 16
        self.y = self.y
      end
    else
      @cursor_rect.y -= 16
    end
    @index -= 1
  end
  # Update the choice display when player hit DOWN
  def update_cursor_down
    @index += 1
    if @index >= @choices.size
      @index -= 1
      update_cursor_up until @index == 0
      return
    end
    if(@choices.size > MaxChoice)
      if(@index < DeltaChoice or 
          @index > (@choices.size - DeltaChoice))
        @cursor_rect.y += 16
      else
        @oy += 16
        self.y = self.y
      end
    else
      @cursor_rect.y += 16
    end
  end
  # Change the window builder and rebuild the window
  def window_builder=(v)
    super(v)
    build_window
  end
  # Build the window : update the height of the window and draw the options
  def build_window
    max = @choices.size
    max = MaxChoice if max > MaxChoice
    self.height = max * 16 + @window_builder[5] * 2
    self.refresh
  end
  # Draw the options
  def refresh
    @texts.each { |text| text.dispose }
    @texts.clear
    @choices.each_index do |i|
      text = PFM::Text.detect_dialog(@choices[i]).dup
      text.gsub!(/\\[Cc]\[([0-9]+)\]/) { @colors[i] = $1.to_i ; nil}
      text.gsub!(/\\t\[(.*),(.*)\]/) { ::PFM::Text.parse($1.to_i, $2.to_i) }
      text.gsub!(/\\d\[(.*),(.*)\]/) { $daycare.parse_poke($1.to_i, $2.to_i) }
      add_text(0, i * 16, @width, 16, text, 0).load_color(@colors[i])
    end
  end
  # Change the z superiority
  # @param v [Numeric]
  def z=(v)
    super(v)
    @text_viewport.z = v + 1
  end
  # Change the x position
  # @param v [Numeric]
  def x=(v)
    super(v)
    v += @window.viewport.rect.x if @window.viewport
    @text_viewport.rect.set(v + @cursor_rect.width + @cursor_rect.x + @ox.to_i, nil)
  end
  # Change the y position
  # @param v [Numeric]
  def y=(v)
    super(v)
    v += @window.viewport.rect.y if @window.viewport
    @text_viewport.rect.set(nil, v + @oy.to_i)
  end
  # Tells the choice is done
  # @return [Boolean]
  def validated?
    return (Input.trigger?(:A) or (Mouse.trigger?(:left) and @window.simple_mouse_in?))
  end
  # Function that creates a new Window_Choice for Window_Message
  # @param text [Text] a Text that has the right settings (to calculate the width)
  # @param window [Game_Window] a window that has the right window_builder (to calculate the width)
  # @param intern_window [Game_Window] a window that has the right z superiority (to calculate the z superiority)
  # @return [Window_Choice] the choice window.
  def self.generate_for_message(text, window, intern_window)
    #>Initialisation
    width = w = 10
    #>Calcul de la taille de la fenêtre
    $game_temp.choices.each do |i|
      i = i.gsub(/\\t\[(.*),(.*)\]/) { ::PFM::Text.parse($1.to_i, $2.to_i) }
      i = i.gsub(/\\d\[(.*),(.*)\]/) { $daycare.parse_poke($1.to_i, $2.to_i) }
      w = text.text_width(i.gsub(/\\[Cc]\[([0-9]+)\]/, nil.to_s))
      width = w if(w > width)
    end
    #>Génération de la fenêtre de choix
    w = window.window_builder[4]
    choice_window = Window_Choice.new(width + w*2 + 8, $game_temp.choices)
    choice_window.z = intern_window.z + 1
    if($game_switches[::Yuki::Sw::MSG_ChoiceOnTop])
      choice_window.x = choice_window.y = 2
    else
      choice_window.x = intern_window.x + window.width - width - w*2 - 8
      if($game_system.message_position == 2)
        choice_window.y = intern_window.y - choice_window.height-2
      else
        choice_window.y = intern_window.y + window.height + 2
      end
    end
    Graphics.sort_z
    return choice_window
  end
end
