# Display a message window
# @author Nuri Yuri
# @deprecated Don't use this otherwise your script will be broken once I removed this script !
#   Use Yuki::Message instead
class Window_Message < Game_Window
  # Constant that holds the marker actions
  MarkerActions = [
    lambda { |_binding, marker| },
    # 1 -> Color
    lambda { |_binding, marker| 
      _binding.local_variable_set(:color, marker.last % GameData::Colors::COLOR_COUNT)
    },
    # 2 -> Wait
    lambda { |_binding, marker| marker.last.times { _binding.receiver.message_update_processing } },
    # 3 -> Style
    lambda { |_binding, marker| 
      _binding.local_variable_set(:style, marker.last)
    },
    # 4 -> Make text bigger
    lambda { |_binding, marker| 
      text = _binding.local_variable_get(:text)
      if text
        text.size = Font::FONT_SIZE
        text.y += 4
        _binding.local_variable_set(:x, text.x + text.real_width)
      end
    },
  ]
  # Name of the window skin in Graphics/Windowskins/
  WindowSkin = "Message"#"M_16"
  # Name of the pause skin in Graphics/Windowskins/
  PauseSkin = "Pause2"
  # Anti-slash character
  S_sl = "\\"
  # Protected Anti-Slash (special_command processing)
  S_000 = "\000"
  # Color change char
  S_001 = "\001"
  # Wait char
  S_002 = "\x02"
  # New Line char (add 16 to y)
  S_n = "\n"
  # Height of a line
  LineHeight = 16
  # Number of line in the message
  LineCount = 2
  # If the message is still drawing (block some processes in #update)
  # @return [Boolean]
  attr_accessor :drawing_message
  # If the message doesn't wait the player to hit A to terminate
  # @return [Boolean]
  attr_accessor :auto_skip
  # If the window message doesn't fade out
  # @return [Boolean]
  attr_accessor :stay_visible
  # Variable that holds the GamePlay::InputNumber object
  # @return [GamePlay::InputNumber]
  attr_accessor :input_number_window
  # Create a new Window_Message
  # @param viewport [Viewport, nil] the viewport in which the Window_Message is shown
  def initialize(viewport=nil)
    super(viewport)
    init_window
    @fade_in = false
    @fade_out = false
    @input_number_window = nil
    @choice_window = nil
    @contents_showing = false
    @drawing_message = false
    @auto_skip = false
    @stay_visible = false
    @gold_window = nil
    reset_window
    @text_sample = Text.new(0, nil, 0, 0, 1, 1, " ", 0)
    @text_sample.visible = false
  end
  # Initialize the window Parameter
  def init_window
    @text_viewport = Viewport.create(0, 0, 320, LineHeight * LineCount)
    self.width = 316
    self.height = 48
    self.x = 2
    self.z = 10000
    @pause_x=@width-15
    @pause_y=@height-18
    update_windowskin
    self.pauseskin=RPG::Cache.windowskin(PauseSkin)
    self.visible=false
  end
  # Update the windowskin
  def update_windowskin
    windowskin_name = $game_system.windowskin_name
    if @windowskin_name != windowskin_name
      if windowskin_name[0, 2] == "M_" # SkinHGSS
        self.window_builder = ::GameData::Windows::MessageHGSS
      else #Skin PSDK
        self.window_builder = ::GameData::Windows::MessageWindow
      end
      self.windowskin = RPG::Cache.windowskin(@windowskin_name = windowskin_name)
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
    @text_viewport.rect.set(v + @ox.to_i, nil)
  end
  # Change the y position
  # @param v [Numeric]
  def y=(v)
    super(v)
    v += @window.viewport.rect.y if @window.viewport
    @text_viewport.rect.set(nil, v + @oy.to_i)
  end
  # Show the fade in during the update
  # @return [Boolean] if the update function skips
  def update_fade_in
    if @fade_in
      update_windowskin if self.contents_opacity == 0
      self.contents_opacity += 24
      @fade_in = false if @contents_opacity == 255
      return true
    end
    return false
  end
  # Show the Input Number Window
  # @return [Boolean] if the update function skips
  def update_input_number
    if @input_number_window
      @input_number_window.update
      #>Validation
      if Input.trigger?(:A)
        $game_system.se_play($data_system.decision_se)
        $game_variables[$game_temp.num_input_variable_id] =
          @input_number_window.number
        $game_map.need_refresh = true
        @input_number_window.dispose
        @input_number_window = nil
        terminate_message
      end
      return true
    end
    return false
  end
  # Skip the choice during update
  # @return [Boolean] if the function skips
  def update_choice_skip
    return false
  end
  # Autoskip condition for the choice
  # @return [Boolean]
  def update_choice_auto_skip
    return @auto_skip
  end
  # Show the choice during update
  # @return [Boolean] if the update function skips
  def update_choice
    if @contents_showing
      @choice_window.update if @choice_window
      #Si il n'y a pas de choix
      if $game_temp.choice_max <= 0
        return true if update_choice_skip
        @pause = true
        if Input.trigger?(:A) or (Mouse.trigger?(:left) and @window.simple_mouse_in?)
          $game_system.se_play($data_system.cursor_se)
          terminate_message
        elsif @auto_skip
          terminate_message
        end
      else
        #>Annulation
        if $game_temp.choice_cancel_type > 0 and Input.trigger?(:B)
          $game_system.se_play($data_system.cancel_se)
          $game_temp.choice_proc.call($game_temp.choice_cancel_type - 1)
          terminate_message
        #>Validation
        elsif Input.trigger?(:A) or (Mouse.trigger?(:left) and @choice_window.simple_mouse_in?)
          $game_system.se_play($data_system.decision_se)
          $game_temp.choice_proc.call(@choice_window.index)
          terminate_message
        end
      end
      return true
    end
    return false
  end
  # Show the message text
  # @return [Boolean] if the update function skips
  def update_text_draw
    if @fade_out == false and $game_temp.message_text != nil
      @contents_showing = true
      $game_temp.message_window_showing = true
      reset_window
      text_dispose
      @fade_in = true
      self.visible = true
      self.contents_opacity = 0
      self.opacity = $game_temp.message_text.size == 0 ? 0 : 255
      refresh
      #Graphics.frame_reset
      return true
    end
    return false
  end
  # Fade the window message out
  # @return [Boolean] if the update function skips
  def update_fade_out
    if self.visible and !@stay_visible
      @fade_out = true
      self.opacity -= 48
      if @opacity == 0
        text_dispose
        self.visible = false
        self.opacity = 255
        @fade_out = false
        $game_temp.message_window_showing = false
      end
    elsif @stay_visible and $game_temp.message_window_showing
      $game_temp.message_window_showing = false
    end
    return false
  end
  # Update the Window_Message processing
  def update
    super
    return if update_fade_in
    #>On empêche le reste des mises à jour si le message est entrain d'être dessiné
    return if @drawing_message
    #>Si on entre un nombre
    return if update_input_number
    #>Si on affiche ce qui suit le message (choix)
    return if update_choice
    #>Si on a du texte à afficher
    return if update_text_draw
    #>Si le traitement est arrivé à son terme
    return if update_fade_out
  end
  # Generate the choice window
  def generate_choice_window
    if($game_temp.choice_max>0)
      @choice_window = ::Window_Choice.generate_for_message(@text_sample, self, @window)
    elsif $game_temp.num_input_digits_max > 0
      @input_number_window = ::GamePlay::InputNumber.new($game_temp.num_input_digits_max)
      if($game_system.message_position != 0)
        @input_number_window.y = self.y - @input_number_window.bitmap.height - 2
      else
        @input_number_window.y = self.y + self.height + 2
      end
      @input_number_window.z = self.z+1
      @input_number_window.update
    end
    @drawing_message = false
  end
  # Generate the list of text refresh instruction
  # @param text [String]
  def generate_text_instructions(text)
    max_width = @width - @ox * 2 #(@windowskin.width - @window_builder[0] - @window_builder[2]) - @ox - 2
    markers = []
    text.gsub!(/([\x01-\x0F])\[([0-9]+)\]/) {  markers << [$1.getbyte(0), $2.to_i]; S_000 }
    texts = text.split(S_000)
    if(texts.first.size > 0) # when blabla\c[1]blabla
      markers.insert(0,[1, get_default_color])
    else
      texts.shift
    end
    instructions = []
    x = 0
    texts.each do |text|
      x = adjust_text_lines(x, max_width, text, instructions)
    end
    @markers = markers
    @instructions = instructions
  end
  # Regexp that catch some punctuation terminaisons
  Ponctuation = /(\.|!|\?|…)/
  # Adjust the line of text by adding instructions to the stack
  # @param x [Integer] start x
  # @param max_width [Integer] width of the line
  # @param text [String] the text to display
  # @param instructions [Array] the instructions
  # @param no_split [Boolean] indicate the function calculates the line
  # @return [Integer] the new x
  def adjust_text_lines(x, max_width, text, instructions, no_split = false)
    unless no_split
      arr = []
      instructions << arr
      return x if text.size == 0
      return (arr << :new_line; x) if text == S_n
      text.split(S_n).each_with_index do |line, i|
        (arr << :new_line; x = 0) if i > 0
        x = adjust_text_lines(x, max_width, line, arr, true)
      end
    else
      ponct_detect = $game_switches[Yuki::Sw::MSG_Ponctuation]
      sw = @text_sample.text_width(" ")# + 1
      words = text.getbyte(0) != 32 ? "" : " "
      text.split(" ").each do |word|
        w = @text_sample.text_width(word)
        if(x + w > max_width)
          x = 0
          instructions << words if words.size > 0
          instructions << :new_line
          words = ""
        end
=begin
        if(ponct_detect and word =~ Ponctuation)
          instructions << :new_line
        end
=end
        words << word << " "
        x += (w + sw)
      end
      x -= sw if text.getbyte(-1) != 32 and words.rstrip!
      instructions << words if words.size > 0
    end
    return x
  end
  # Wait the user input
  def wait_user_input
    self.pause = true
    until Input.trigger?(:A) or (Mouse.trigger?(:left) and @window.simple_mouse_in?)
      message_update_processing
    end
    $game_system.se_play($data_system.cursor_se)
    self.pause = false
  end
  # Progress in the text display
  # @param text [LiteRGSS::Text] the text element
  # @param str [String] the text shown
  # @param counter [Integer] the counter
  # @return [Integer] the new counter
  def progress(text, str, counter)
    speed = $options.message_speed
    text.nchar_draw = 0
    text.opacity = self.contents_opacity
    until text.nchar_draw >= str.size
      break if stop_message_proces?
      text.nchar_draw += 1
      counter += 1
      if Input.trigger?(:A) or (Mouse.trigger?(:left) and @window.simple_mouse_in?) # Skip request
        text.nchar_draw = str.size
        return -1
      end
      if counter >= speed
        message_update_processing
        counter = 0
      end
    end
    return counter
  end
  # Perform a line transition
  def line_transition
    LineHeight.times do
      break if stop_message_proces?
      @text_viewport.oy += 1
      message_update_processing
    end
  end
  # Get the text style code
  # @param str [String] text style b = Bold, i = Italic, r = Reset
  # @return [Integer] the style integer
  def get_style_code(str)
    return 0 if str.include?('r')
    code = str.include?('b') ? 1 : 0
    code |= str.include?('i') ? 2 : 0
    return code
  end
  # Set the text style
  # @param text [LiteRGSS::Text]
  # @param style [Integer] 1 = bold, 2 = italic, 3 = bold & italic
  def set_text_style(text, style)
    text.bold = true if (style & 1) != 0
    text.italic = true if (style & 2) != 0
  end
  # Return the default text color
  # @return [Integer]
  def get_default_color
    return 0
  end
  # Return the default text style
  # @return [Integer]
  def get_default_style
    return 0
  end
  # Call a marker action
  # @param _binding [Binding] the binding of the refresh method
  # @param maker [Array]
  def call_marker_action(_binding, marker)
    action = MarkerActions[marker.first]
    action.call(_binding, marker) if action
  end
  # Draw the message
  # @param lineheight [Integer] height of the line
  def refresh(lineheight = LineHeight)
    return unless $game_temp.message_text
    @drawing_message = true
    @text_viewport.oy = 0
    text = $game_temp.message_text
    text = ::PFM::Text.parse_string_for_messages(text)
    text.gsub!(/\\[Gg]/) { show_gold_window }
    text.gsub!(/\[WAIT ([0-9]+)\]/) { "\x02[#{$1}]"}
    text.gsub!(/\\[Cc]\[([0-9]+)\]/) { "\001[#{$1}]" }
    text.gsub!(/\\[Ss]\[([bir]+)\]/) { "\x03[#{get_style_code($1)}]" }
    text.gsub!(/\\\^/) { "\x04[0]" }
    text.gsub!(S_000, S_sl)
    x = y = 0
    color = get_default_color
    style = get_default_style
    skip = false
    counter = 0
    generate_text_instructions(text)
    @instructions.each_with_index do |instr_arr, i|
      break if stop_message_proces?
      marker = @markers[i]
      if marker
        call_marker_action(binding, marker)
=begin
        case marker.first
        when 1 # Color
          color = marker.last % GameData::Colors::COLOR_COUNT
        when 2 # Wait
          marker.last.times { message_update_processing }
        when 3 # Style
          style = marker.last
        end
=end
      end
      instr_arr.each do |instr|
        if(instr == :new_line)
          x = 0
          y += lineheight
          if y >= @text_viewport.rect.height
            wait_user_input
            line_transition
          end
          next
        end
        text = add_text(x, y, 1, lineheight, instr, 0).load_color(color)
        set_text_style(text, style)
        x += text.real_width
        counter = progress(text, instr, counter) unless skip
        skip = (counter == -1 || Input.trigger?(:A))
      end
    end
    return if stop_message_proces?
    generate_choice_window
  end
  # Update the scene and Graphics during the message draw processing
  def message_update_processing
    Graphics.update
    $scene.update
  end
  # Terminate the message display
  def terminate_message
    self.active = false
    self.pause = false
    @contents_showing = false
    $game_temp.message_proc.call if $game_temp.message_proc != nil
    $game_temp.message_text = nil
    $game_temp.message_proc = nil
    $game_temp.choice_start = 99
    $game_temp.choice_max = 0
    $game_temp.choice_cancel_type = 0
    $game_temp.choice_proc = nil
    $game_temp.num_input_start = -99
    $game_temp.num_input_variable_id = 0
    $game_temp.num_input_digits_max = 0
    if(@gold_window)
      @gold_window.dispose
      @gold_window = nil
    end
    @choice_window.dispose if(@choice_window)
    @choice_window = nil
    @auto_skip = false
  end
  # Release the ressources used by this Window_Message object
  def dispose
    terminate_message
    text_dispose
    $game_temp.message_window_showing = false
    @input_number_window.dispose if @input_number_window != nil
    super
    @text_sample.dispose
  end
  # Adjust the window position on screen
  def reset_window
    case $game_system.message_position
    when 0 # En Haut
      self.y=2
    when 1 # Au centre
      self.y=96
    when 2 # En bas
      self.y=190
    end
    self.back_opacity=($game_system.message_frame == 0 ? 255 : 0)
  end
  # Show a window that tells the player how much money he got
  def show_gold_window
    return if @gold_window
    @gold_window = ::Game_Window.new(self.viewport)
    wb = @gold_window.window_builder = ::GameData::Windows::MessageHGSS
    @gold_window.y = 2
    @gold_window.z = self.z + 1
    @gold_window.width = 96 + self.windowskin.width - wb[2]
    @gold_window.height = 32 + self.windowskin.height - wb[3]
    @gold_window.x = 318 - @gold_window.width
    @gold_window.windowskin = self.windowskin
    @gold_window.add_text(0, 0, 96, 16, ::GameData::Text.get(11, 6))
    @gold_window.add_text(0, 16, 96, 16, ::PFM::Text.parse(11, 9, ::PFM::Text::NUM7R => $pokemon_party.money.to_s), 2)
  end

  private

  # Tell the process method of message to stop processing
  # @return [Boolean]
  def stop_message_proces?
    return $scene.is_a?(Yuki::SoftReset)
  end
end
