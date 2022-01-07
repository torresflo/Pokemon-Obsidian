module UI
  module Hall_of_Fame
    # Class that define the Trainer Infos text box stack
    class Trainer_Infos_Text_Box < SpriteStack
      # The name text
      # @return [Text]
      attr_accessor :name
      # The id_no text
      # @return [Text]
      attr_accessor :id_no
      # The play_time text
      # @return [Text]
      attr_accessor :play_time
      Y_FINAL = 202
      WHITE_COLOR = Color.new(255, 255, 255, 255)
      # Initialize the SpriteStack
      # @param viewport [Viewport]
      def initialize(viewport)
        super(viewport, *initial_coordinates)
        @box = add_sprite(0, 0, box_filename)
        @name = add_text(*name_coordinates, $trainer.name, 0)
        @id_no = add_text(*id_no_coordinates,
                          format('%<text>s %<id>05d', text: text_get(34, 2), id: $trainer.id % 100_000), 0)
        @play_time = add_text(*play_time_coordinates, PFM.game_state.trainer.play_time_text, 2, type: Text)
        @name.fill_color = WHITE_COLOR
        @name.draw_shadow = false
        @name.opacity = 0
        @id_no.fill_color = WHITE_COLOR
        @id_no.draw_shadow = false
        @id_no.opacity = 0
        @play_time.fill_color = WHITE_COLOR
        @play_time.draw_shadow = false
        @play_time.opacity = 0
      end

      # The SpriteStack initial coordinates
      # @return [Array<Integer>] the coordinates
      def initial_coordinates
        return 10, 240
      end

      # The base filename of the window
      # @return [String]
      def box_filename
        'hall_of_fame/text_window'
      end

      # Get the constant's value
      # @return [Integer]
      def y_final
        Y_FINAL
      end

      # The base coordinates of the name text
      # @return [Array<Integer>] the coordinates
      def name_coordinates
        return 42, 5, 57, 16
      end

      # The base coordinates of the id_no text
      # @return [Array<Integer>] the coordinates
      def id_no_coordinates
        return 113, 5, 88, 16
      end

      # The base coordinates of the play_time text
      # @return [Array<Integer>] the coordinates
      def play_time_coordinates
        return 202, 5, 55, 16
      end
    end
  end
end
