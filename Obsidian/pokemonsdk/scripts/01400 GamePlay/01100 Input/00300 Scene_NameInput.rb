#encoding: utf-8

# Name Input scene
# @author Nuri Yuri
class Scene_NameInput
  # Character surface widths. Its a list of list of widthds by lines.
  RectWidths = [Array.new(11,20) + [50], Array.new(10,20) + [60], Array.new(12,20), Array.new(12,20), [180,60]]
  # List of character x coordinate
  X_Coords = [[],[],[],[],[]]
  # First x coordinate of each line
  Bases_X = [20, 30, 40, 50, 50]
  # Y coordinate of each line
  Bases_Y = [60, 95, 130, 165, 200]
  # Cursor name by character surface width
  Cursors = {20 => "NameInput_Selectcase", 50 => "NameInput_Selecteffacer", 
  60 => "NameInput_Selectentree", 180 => "NameInput_Selectespace"}
  # List of character when Name Input scene is in Maj state
  Chars_Maj = [["♂","♀","+","-","*","/","=","%","(",")","'","Effacer"],
  ["A","Z","E","R","T","Y","U","I","O","P","Valider"],
  ["Q","S","D","F","G","H","J","K","L","M","Ç","À"],
  ["W","X","C","V","B","N",".","Ê","É","È","Ë","Ï"],
  ["Espace","Maj"]]
  # List of character when Name Input scene is in Minus state
  Chars_Min = [["1","2","3","4","5","6","7","8","9","0","'","Effacer"],
  ["a","z","e","r","t","y","u","i","o","p","Valider"],
  ["q","s","d","f","g","h","j","k","l","m","ç","à"],
  ["w","x","c","v","b","n",".","ê","é","è","ë","ï"],
  ["Espace","Maj"]]
  # The space character
  Space = " "
  # Return the choosen name
  # @return [String]
  attr_reader :return_name
  # Create a new Scene_NameInput scene
  # @param default_name [String] the choosen name if no choice
  # @param max_length [Integer] the maximum number of characters in the choosen name
  # @param character [PFM::Pokemon, String, nil] the character to display
  def initialize(default_name, max_length, character = nil)
    @default_name = default_name
    @name = default_name.split(//)[0,max_length]
    @max_length = max_length
    @viewport = Viewport.create(:main, 20000)
    @background = Sprite.new(@viewport)
      .set_bitmap("NameInput_Fond", :interface)
    adjust_char_texts
    init_key_text
    init_input_chars
    @cursor = Sprite.new(@viewport)
    @maj_c = Sprite::WithColor.new(@viewport)
      .set_position(230, 200)
      .set_bitmap("NameInput_Selectentree", :interface)
      .set_color([0, 1.0, 0.39, 1.0])
    @character = Sprite.new(@viewport)
    #>Pokémon
    if(character.class == PFM::Pokemon)
      @character.bitmap = character.icon
      @character.set_position(18, 8).mirror = true
      @character.src_rect.width = @character.src_rect.height
    elsif(character)
      @character.bitmap = RPG::Cache.character(character)
      width = @character.bitmap.width/4
      height = @character.bitmap.height/4
      @character.src_rect.set(0, 0, width, height)
      @character.set_position(10 + (48 - width)/2, (48 - height) / 2)
    end
    @index_x = 0
    @index_y = 0
    @opacity = 10
  end
  # Scene entry point
  def main
    draw_chars
    update_cursor
    Graphics.transition
    @running = true
    while @running && $scene
      Graphics.update
      update
    end
    Graphics.freeze
    dispose
    ::Scheduler.start(:on_scene_switch, self.class)
    return self
  end
  private
  # Function that ajust the char text array
  def adjust_char_texts
    Chars_Min[0][-1] = Chars_Maj[0][-1] = ext_text(9000, 22)
    Chars_Min[-1][0] = Chars_Maj[-1][0] = ext_text(9000, 23)
    Chars_Min[-1][1] = Chars_Maj[-1][1] = ext_text(9000, 24)
    Chars_Min[1][-1] = Chars_Maj[1][-1] = ext_text(9000, 25)
  end
  # Update the scene processing
  def update
    #>Mise à jour de l'opacité du curseur
    op = @cursor.opacity
    @cursor.opacity += @opacity
    @opacity -= 2*@opacity if op == @cursor.opacity
    unless(@cursor.visible)
      return update_keyboard
    end
    #>Mise à jour des positions
    if(Input.repeat?(:UP))
      if @index_y == 4 and @index_x == 1
        @index_x = 10
        @maj_c.opacity = 255
      elsif(@index_y == 2 and @index_x > 10)
        @index_x = 10
      elsif(@index_y == 0)
        @index_x /= 10
        @maj_c.opacity = 0 if @index_x == 1
      end
      @index_y = (@index_y - 1) % Bases_Y.size
      update_cursor
    elsif(Input.repeat?(:DOWN))
      if @index_y == 4 and @index_x == 1
        @index_x = 10
        @maj_c.opacity = 255
      elsif(@index_y == 0 and @index_x > 10)
        @index_x = 10
      elsif(@index_y == 3)
        @index_x /= 10
        @maj_c.opacity = 0 if @index_x == 1
      end
      @index_y = (@index_y + 1) % Bases_Y.size
      update_cursor
    elsif(Input.repeat?(:RIGHT))
      @index_x = (@index_x + 1) % RectWidths[@index_y].size
      @maj_c.opacity = ((@index_y == 4 and @index_x == 1) ? 0 : 255)
      update_cursor
    elsif(Input.repeat?(:LEFT))
      @index_x = (@index_x - 1) % RectWidths[@index_y].size
      @maj_c.opacity = ((@index_y == 4 and @index_x == 1) ? 0 : 255)
      update_cursor
    elsif(Input.trigger?(:B))
      erase_char
    elsif(Input.trigger?(:A))
      if(@index_y == 0 and @index_x == 11)
        erase_char
      elsif(@index_y == 1 and @index_x == 10)
        validate
      elsif(@index_y == 4)
        if(@index_x == 0)
          add_char(Space)
        else
          $game_system.se_play($data_system.decision_se)
          @maj_c.visible = !@maj_c.visible
          draw_chars
        end
      else
        add_char(get_chars_arr[@index_y][@index_x])
        auto_set_validate
      end
    elsif(Input::Keyboard.press?(Input::Keyboard::RControl))
      unless @lastctrl
        @cursor.visible = false
        @lastctrl = true
      end
    else
      @lastctrl = false
    end
  end
  # Update KeyBoard interactions
  def update_keyboard
    if(text = Input.get_text)
      text.split(//).each do |c|
        if(c.getbyte(0) == 8)
          erase_char
        elsif(c.getbyte(0) == 13)
          return validate
        else
          add_char(c) if(@name.size < @max_length)
        end
      end
    elsif(Input::Keyboard.press?(Input::Keyboard::RControl))
      unless @lastctrl
        @cursor.visible = true
        @lastctrl = true
      end
    else
      @lastctrl = false
    end
  end
  # Add a character to the name
  # @param char [String]
  def add_char(char)
    if(@name.size < @max_length)
      $game_system.se_play($data_system.decision_se)
      @name.push(char)
      draw_name
    else
      $game_system.se_play($data_system.buzzer_se)
    end
  end
  # Update the cursor coordinate and bitmap
  def update_cursor
    @cursor.x = X_Coords[@index_y][@index_x]
    @cursor.y = Bases_Y[@index_y]
    @cursor.bitmap = RPG::Cache.interface(Cursors[RectWidths[@index_y][@index_x]])
  end
  # Validate the name input (load the return_name attribute and stop the scene)
  def validate
    @running = false
    $game_system.se_play($data_system.decision_se)
    @return_name = @name.size > 0 ? @name.join(nil.to_s) : @default_name
  end
  # Remove a char from the entered name
  def erase_char
    unless @name.pop
      $game_system.se_play($data_system.buzzer_se)
    else
      $game_system.se_play($data_system.decision_se)
      draw_name
    end
  end
  # Initialize the key texts
  def init_key_text
    chars = Chars_Maj
    @key_texts = Array.new(chars.size) do |i|
      x = Bases_X[i]
      y = Bases_Y[i] - Text::Util::FOY
      char_list = chars[i]
      rects = RectWidths[i]
      Array.new(char_list.size) do |j|
        X_Coords[i][j] = x
        width = rects[j]
        t = Text.new(0, @viewport, x, y, width, 30, char_list[j], 1)
        t.load_color(8) if width > 20
        x += width
        next(t)
      end
    end
  end
  # Draw the character layout
  def draw_chars
    chars = get_chars_arr
    @key_texts.each_with_index do |keys_list, i|
      char_list = chars[i]
      keys_list.each_with_index do |text, j|
        text.text = char_list[j] if text.text != char_list[j]
      end
    end
    draw_name
  end
  # Return the character array (input layout)
  def get_chars_arr
    @maj_c.visible ? Chars_Maj : Chars_Min
  end
  # Initialize the input char texts and underscores
  def init_input_chars
    x = (320 - 18 * @max_length)/2
    y = 16 - Text::Util::FOY
    bmp = RPG::Cache.interface("NameInput_Underscore")
    @input_texts = Array.new(@max_length)
    @input_underscore = Array.new(@max_length)
    @max_length.times do |i|
      @input_underscore[i] = Sprite.new(@viewport).set_bitmap(bmp).set_position(x, 32)
      @input_texts[i] = Text.new(0, @viewport, x, y, 18, 16, nil.to_s, 1).load_color(8)
      x += 18
    end
  end
  # Draw the name
  def draw_name
    sz = @name.size
    @max_length.times do |i|
      @input_underscore[i].opacity = i == sz ? 128 : 255
      text = @input_texts[i]
      c = @name[i].to_s
      text.text = c if c != text.text
    end
  end
  # Dispose the scene
  def dispose
    @viewport.dispose
  end
  # Automatically set the cursor to validate key when the name is full
  def auto_set_validate
    if @name.size == @max_length
      @index_y = 1
      @index_x = 10
      update_cursor
    end
  end
  # Number Input (Codes) scene
  class NumInput < Scene_NameInput
    # Constant that define numeric input for the NumInput ui
    Chars_Num = [["1","2","3","4","5","6","7","8","9","0","1","Effacer"],
    ["4","5","6","7","8","9","0","1","2","3","Valider"],
    ["6","7","8","9","0","1","2","3","4","5","6","7"],
    ["8","9","0","1","2","3","4","5","6","7","8","9"],
    ["Espace","Maj"]]
    # Initialize the parent scene with no default name and the right amount of character
    def initialize
      super("", 17)
    end
    # Function that ajust the char text array
    def adjust_char_texts
      Chars_Num[0][-1] = ext_text(9000, 22)
      Chars_Num[-1][0] = ext_text(9000, 23)
      Chars_Num[-1][1] = ext_text(9000, 24)
      Chars_Num[1][-1] = ext_text(9000, 25)
    end
    # Add the CTRL+V / right click interaction
    def update
      if Mouse.press?(:right) or 
          (text = Input.get_text and text.getbyte(0) == 22)
        name = Yuki.get_clipboard.to_i.to_s
        if name and name.size <= 17
          @name = name.split(//)
          draw_name
          auto_set_validate
        end
      end
      super
    end
    # Add a character but ignore the Space character
    # @param char [String]
    def add_char(char)
      return if char == Space
      super
    end
    # Return the character layout (Numeric characters)
    def get_chars_arr
      Chars_Num
    end
  end
end
