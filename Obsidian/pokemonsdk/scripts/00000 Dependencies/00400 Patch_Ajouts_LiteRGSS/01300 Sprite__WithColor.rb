module LiteRGSS
  class Sprite
    # Define a sprite that mix with a color
    class WithColor < ShaderedSprite
      # Create a new Sprite::WithColor
      # @param viewport [LiteRGSS::Viewport, nil]
      def initialize(viewport = nil)
        super(viewport)
        self.shader = Shader.new(Shader::GeneralColorSprite)
      end

      # Set the Sprite color
      # @param array [Array(Numeric, Numeric, Numeric, Numeric), LiteRGSS::Color] the color (values : 0~1.0)
      # @return [self]
      def set_color(array)
        shader.set_float_uniform('color', array)
        return self
      end
    end
  end
end
