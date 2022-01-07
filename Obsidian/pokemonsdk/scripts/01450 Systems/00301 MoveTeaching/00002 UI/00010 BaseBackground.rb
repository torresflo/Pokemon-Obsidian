module UI
  module MoveTeaching
    # UI part displaying the background of the Skill Learn scene
    class BaseBackground < SpriteStack
      # Create the Background
      # @param viewport [Viewport]
      def initialize(viewport)
        super(viewport, *background_coordinates, default_cache: :interface)
        create_background
      end

      private

      # Create the background
      def create_background
        add_background(background_name)
      end

      # @return [Array] the background coordinates
      def background_coordinates
        return 3, 8
      end

      # @return [String] the background name
      def background_name
        'skill_learn/skill_learn'
      end
    end
  end
end