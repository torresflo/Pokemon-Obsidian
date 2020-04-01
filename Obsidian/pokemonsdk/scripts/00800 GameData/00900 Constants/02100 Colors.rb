module GameData
  # Commonly used Colors
  # @author Nuri Yuri
  module Colors
    # Number of color for messages
    COLOR_COUNT = 20
    # Text color (inside)
    BattleBar_Text_IN = Color.new(255, 255, 255)
    # Text color (stroke)
    BattleBar_Text_OUT = Color.new(33, 33, 33)
    # We load the color info image
    RPG::Cache.load_windowskin
    # @type [Yuki::VD, nil]
    windowskin_vd = RPG::Cache.instance_variable_get(:@windowskin_data)
    data = windowskin_vd&.read_data('_colors')
    # We load the color image, the `data ? true : false` is wanted because of the internal functions
    # @type [Image]
    color_image = data ? Image.new(data, true) : Image.new('graphics/windowskins/_colors.png')
    color_image.width.times do |i|
      Fonts.define_outline_color(i, color_image.get_pixel(i, 0))
      Fonts.define_fill_color(i, color_image.get_pixel(i, 1))
      Fonts.define_shadow_color(i, color_image.get_pixel(i, 2))
    end
    # Poison flash color
    PSN = Color.new(123, 55, 123, 128)
    # Transparent color
    Transparent = Color.new(0, 0, 0, 0)
  end
end
