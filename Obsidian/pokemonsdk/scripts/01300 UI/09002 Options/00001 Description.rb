module UI
  module Options
    # Class that shows the option description
    class Description < SpriteStack
      # Create a new InfoWide
      # @param viewport [Viewport]
      def initialize(viewport)
        super(viewport, 0, 45)
        add_background('options/description')
        @name = add_text(3, 19, 0, 13, :name, type: SymText, color: 25)
        @descr = add_text(3, 37, 151, 16, :description, type: SymMultilineText)
      end
    end
  end
end
