module UI
  module Hall_of_Fame
    # The class that define the type background displayed during phase 1
    class Type_Background < SpriteStack
      # The non-translucent backgrounds
      # @return [Array<Sprite>]
      attr_accessor :type_foregrounds
      # The translucent backgrounds
      # @return [Array<Sprite>]
      attr_accessor :type_backgrounds
      # Initialize the SpriteStack
      # @param viewport [Viewport]
      def initialize(viewport)
        super(viewport)
        @type_backgrounds = Array.new($actors.size) { add_sprite(*foreground_pos, NO_INITIAL_IMAGE) }
        @type_foregrounds = Array.new($actors.size) { add_sprite(*foreground_pos, NO_INITIAL_IMAGE) }
        # pkm = [PFM::Pokemon]
        $actors.each_with_index do |pkm, index|
          @type_foregrounds[index].set_bitmap('hall_of_fame/' + pkm.type1.to_s, :interface).opacity = 0
          @type_backgrounds[index].set_bitmap('hall_of_fame/' + pkm.type1.to_s, :interface).opacity = 0
        end
      end

      private

      # The initial position of the foregrounds
      # @return [Array<Integer>] the coordinates
      def foreground_pos
        return 0, 0
      end

      # The initial position of the backgrounds
      # @return [Array<Integer>] the coordinates
      def background_move
        return 0, 0
      end
    end
  end
end
