module UI
  class List
    # Class that handle the list items, sprite and texts
    # @author Leikt
    class ListItem < SpriteStack
      # Initialize the list item
      # @param viewport [Viewport] the viewport to display
      # @param params [Hash] the item generation parameters
      def initialize(viewport, params)
        super(viewport)
        @width = self.class.retrieve_width(params)
        @height = self.class.retrieve_height(params)
        @modifier = params[:modifier]
      end

      class << self
        # Retrieve item width from the given param
        # @param param [Hash] the param of the item for the list
        # @author Leikt
        def retrieve_width(param)
          unless (width = param[:width])
            width = self::DEFAULT_WIDTH if param[:list_direction] == :horizontal
            width ||= param[:list_width]
            width ||= self::DEFAULT_WIDTH
          end
          return width
        end

        # Retrieve item height from the given param
        # @param param [Hash] the param of the item for the list
        # @author Leikt
        def retrieve_height(param)
          unless (height = param[:height])
            height = self::DEFAULT_HEIGHT if param[:list_direction] == :vertical
            height ||= param[:list_height]
            height ||= self::DEFAULT_HEIGHT
          end
          return height
        end
      end

      # Test if the mouse is in the item
      # @param mouse_x [Integer] the mouse x screen coord
      # @param mouse_y [Integer] the mouse y screen coord
      # @return [Boolean]
      # @author Leikt
      def simple_mouse_in?(mouse_x = Mouse.x, mouse_y = Mouse.y)
        coords = @viewport.translate_mouse_coords(mouse_x, mouse_y)
        return coords[0].between?(@x, @x + @width) &&
               coords[1].between?(@y, @y + @height)
      end

      # Use the proc to modify the x and y value
      def call_modifier(hash)
        @modifier&.call(self, hash)
      end

      # Class that handle an simple text item
      # @author Leikt
      class SimpleText < ListItem
        # Default item height
        # @return [Integer]
        DEFAULT_HEIGHT = 20

        # Default item width
        # @return [Integer]
        DEFAULT_WIDTH = 20

        # Intialize the item
        # @param viewport [Viewport] the viewport to display
        # @param params [Hash] the item generation parameters
        def initialize(viewport, params)
          super(viewport, params)
          @main = add_text 5, 1, @width - 5, @height - 1, ''
        end

        # Change the text value
        # @param value [String] the new value
        def data=(value)
          @main.text = value.to_s
        end
      end

      # Class that handle an vertical list item display with item count
      # @author Leikt
      class LineItem < ListItem
        # Default item height
        # @return [Integer]
        DEFAULT_HEIGHT = 25

        # Default item width
        # @return [Integer]
        DEFAULT_WIDTH = 100

        # Initialize the item
        # @param viewport [Viewport] the viewport to display
        # @param params [Hash] the item generation parameters
        def initialize(viewport, params)
          super(viewport, params)
          @icon = push 0, -2, '', type: ItemSprite
          @text = add_text(32, 0, @width - 32, @height, '')
          @count = add_text(@width - 5 - 20, 0, 0, @height, '', 2)
        end

        # Change the item icon value
        # @param value [Array<Integer, Integer>] Array [item_id, count]
        def data=(values)
          if values && (id = values[0])
            @icon.visible = true
            @icon.data = id
            if id > 0
              # Display item name and count
              @text.text = generate_name(id)
              @count.text = "x#{values[1]}"
            else
              # Display 'return' button
              @text.text = text_get(22, 7)
              @count.text = ''
            end
          else
            # Do not sho anything
            @icon.visible = false
            @text.text = ''
            @count.text = ''
          end
        end

        # Decorate the name of the item if it's a CT / CS
        # @param id [Integer] the item id
        # @return [String]
        def generate_name(id)
          return GameData::Item[id].exact_name
        end
      end

      # Class that handle an horizontal list pokemon icon display
      # @author Leikt
      class ColumnPokemonIcon < ListItem
        # Default item height
        # @return [Integer]
        DEFAULT_HEIGHT = 32

        # Default item width
        # @return [Integer]
        DEFAULT_WIDTH = 32

        # Initialize the item
        # @param viewport [Viewport] the viewport to display
        # @param params [Hash] the item generation parameters
        def initialize(viewport, params)
          super(viewport, params)
          @icon = push @width / 2, @height / 2, '', type: PokemonIconSprite
        end

        # Change the item icon value
        # @param value [PFM::Pokemon] the pokemon to display
        def data=(value)
          @icon.data = value
        end
      end
    end
  end
end
