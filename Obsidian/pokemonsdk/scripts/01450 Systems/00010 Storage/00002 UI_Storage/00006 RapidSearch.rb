module UI
  module Storage
    # Class responsive of showing a rapid search
    class RapidSearch < UI::SpriteStack
      # Create a new rapid search
      # @param viewport [Viewport]
      def initialize(viewport)
        super
        create_stack
      end

      # Update the user input
      def update
        return unless visible

        @user_input.update
      end

      # Get the text of the user input
      # @return [String]
      def text
        @user_input.text
      end

      # Reset the search
      def reset
        @user_input.text = ''
      end

      private

      def create_stack
        create_background
        create_user_input
      end

      def create_background
        add_sprite(0, 217, 'pc/win_txt').set_z(20)
      end

      def create_user_input
        # @type [UI::UserInput]
        @user_input = add_text(0, 217, 0, 23, '', type: UI::UserInput, color: 9)
        @user_input.init(20)
      end
    end
  end
end
