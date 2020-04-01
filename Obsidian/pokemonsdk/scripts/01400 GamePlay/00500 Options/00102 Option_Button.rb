#encoding: utf-8

#noyard
module GamePlay
  class Option_Button
    ButtonBase_Y = 206
    ButtonBase_X = 96
    Button_Image = "Options_Buttons"
    def initialize(type, viewport)
      base_x = 316 - ButtonBase_X * (type + 1)
      @button_image = ::Yuki::Utils.create_sprite(viewport, Button_Image, 
        base_x, ButtonBase_Y, 201, src_rect_div: [0, type, 1, 3])
      @button_sel = ::Yuki::Utils.create_sprite(viewport, Button_Image, 
        base_x, ButtonBase_Y, 202, src_rect_div: [0, 2, 1, 3])
      @text = Text.new(0, viewport, @button_image.x, @button_image.y, 
        @button_image.bitmap.width - 8,
        @button_image.bitmap.height / 3 - Text::Util::FOY,
        GameData::Text.get(42, 1+type), 2)
      @text.z = 202
      draw(false)
    end

    def draw(state)
      @button_sel.visible = state
    end

    def dispose
      @text.dispose
      @button_sel.dispose
      @button_image.dispose
    end

    def simple_mouse_in?
      @button_image.simple_mouse_in?
    end
  end
end
