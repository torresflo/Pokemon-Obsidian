module Graphics
  on_start do
    Graphics.load_icon
  end

  class << self
    # Load the window icon
    def load_icon
      return unless RPG::Cache.icon_exist?('game')

      # @type [Yuki::VD, nil]
      windowskin_vd = RPG::Cache.instance_variable_get(:@icon_data)
      data = windowskin_vd&.read_data('game')
      # @type [Image]
      image = data ? Image.new(data, true) : Image.new('graphics/icons/game.png')
      window.icon = image
      image.dispose
    end

    alias original_swap_fullscreen swap_fullscreen
    # Define swap_fullscreen so the icon is taken in account
    def swap_fullscreen
      original_swap_fullscreen
      load_icon
    end
  end
end
