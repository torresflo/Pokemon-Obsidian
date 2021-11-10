module UI
  # Class that create and handle a list of various items.
  # @author Leikt
  class List
    # Create the list with the given settings :
    #
    # - :x, :y [Integer] the coords of the list in the viewport
    # - :width, :height [Integer] the dimensions of the list
    # - :skin [String] the window skin
    # - :padding_left, :padding_right, :padding_top, :padding_bottom [Integer]
    #     the distance between the edge of the window and the content
    # - :item_type [Class] the item type to display
    # - :item_params [Hash] the parameters of the item (specific to item_type)
    # - :items [Array] data to display
    # - :index [Integer] the index where to display at creation
    # - :mode [Symbol] cursor positionning mode
    # - :cursor [String] the window skin for the cursor
    # - :scrollbar [Hash] the scrollbar info, nil if no scrollbar
    # @param viewport [Viewport] the viewport to use
    # @param kwargs [Hash] the list data
    # @author Leikt
    def initialize(viewport, kwargs = {})
      # Retrieve attributes
      @viewport = viewport
      @direction = kwargs.fetch(:direction, :vertical)
      @x = kwargs.fetch(:x, 0)
      @y = kwargs.fetch(:y, 0)
      @width = kwargs.fetch(:width, 100)
      @height = kwargs.fetch(:height, 150)
      @skin = kwargs.fetch(:skin, Window::DEFAULT_SKIN)
      @padding_left = kwargs.fetch(:padding_left, 0)
      @padding_right = kwargs.fetch(:padding_right, 0)
      @padding_top = kwargs.fetch(:padding_top, 0)
      @padding_bottom = kwargs.fetch(:padding_bottom, 0)
      item_params = @item_params = retrieve_item_params(kwargs[:item_params])
      item_type = @item_type = kwargs.fetch(:item_type, ListItem::SimpleText)
      @items = kwargs.fetch(:items, [])
      start_index = kwargs.fetch(:index, 0)
      mode = kwargs.fetch(:mode, :center)
      cursor = kwargs.fetch(:cursor, nil)
      @scrollbar_params = kwargs.fetch(:scrollbar, nil)
      looped = kwargs.fetch(:looped, false)
      # Create elements
      create_background
      create_content(mode, cursor, looped)
      @content.setup(@items, item_type, item_params)
      @content.moveto(start_index, false)
      if @scrollbar_params
        @scrollbar_params = retrieve_scrollbar_param(@scrollbar_params)
        create_scrollbar(@scrollbar_params)
      end
      enable
    end

    # Update the list, graphics, inputs and controls
    # @author Leikt
    def update
      return unless @enabled

      @content.update
      @scrollbar&.update
    end

    # Get the data displayed by the list
    # @return [Array<Object>]
    def data
      return @content.data
    end

    # Load given data into the list and create the sprites if necessary
    # @param data [Array] the data to display
    # @param item_type [Class] the item type to display
    # @param item_params [Hash] the specific parameters of item creation
    # @author Leikt
    def setup(data, item_type = @item_type, item_params = @item_params)
      @content.setup(data, item_type, retrieve_item_params(item_params))
      @content.refresh
      @scrollbar&.change_ranges(retrieve_scrollbar_param(@scrollbar_params))
    end

    # Return the visible state
    # @return [Boolean]
    # @author Leikt
    def visible
      return @viewport.visible
    end

    # Change the visibility of the list
    # @param value [Boolean] the new visible state
    # @author Leikt
    def visible=(value)
      @viewport.visible = value
    end

    # Return the cursor index
    # @return [Boolean]
    # @author Leikt
    def index
      return @content.index
    end

    # Set the index to given value
    # @param value [Integer] the new index
    # @author Leikt
    def index=(value)
      return unless @enabled

      @content.moveto(value, true)
    end

    # Return the selected object
    # @param mouse_must_be_over [Boolean, false] if true, while return nil if the mouse isn't over the content
    # @return [Object]
    # @author Leikt
    def selected(mouse_must_be_over = false)
      return nil unless @enabled

      return @content.selected(mouse_must_be_over)
    end

    # Sort the item list with the given proc
    # @param sort_block [Block] the proc used to sort the data
    def sort(block)
      @content.sort(block)
    end

    # Filter the data
    # @param filter [Proc] the filter proc
    def filter=(filter)
      @content.filter = filter
      @content.setup(@content.data, @item_type, @item_params)
      @content.refresh
      @scrollbar&.change_ranges(retrieve_scrollbar_param(@scrollbar_params))
    end

    # Enable the list. Make the update running.
    def enable
      @enabled = true
    end

    # Disable the list. Stop the update.
    def disable
      @enabled = false
    end

    # Dispose the list
    # @author Leikt
    def dispose
      @viewport.dispose
      @content.dispose
    end

    # Detect if the mouse is over the content or not
    # @param mouse_x [Integer, Mouse.x] the mouse screen x coord
    # @param mouse_y [Integer, Mouse.y] the mouse screen y coord
    # @return [Boolean]
    # @author Leikt
    def simple_mouse_in?(mouse_x = Mouse.x, mouse_y = Mouse.y)
      return false unless @enabled

      return mouse_x.between?(@viewport.rect.x, @viewport.rect.x + @viewport.rect.width) &&
             mouse_y.between?(@viewport.rect.y, @viewport.rect.y + @viewport.rect.height)
    end

    private

    # Create the background sprite
    # @author Leikt
    def create_background
      @background = Window.new(@viewport, @x, @y, @width, @height, skin: @skin)
    end

    # Create the list content
    # @param mode [Symbol] the cursor positionning mode
    # @param cursor [String, nil] the cursor windowskin name
    # @author Leikt
    def create_content(mode, cursor, looped)
      @content = List::Content.new(
        x: @x + @padding_left + @viewport.rect.x,
        y: @y + @padding_top + @viewport.rect.y,
        z: @viewport.z + 1_000,
        width: @width - @padding_left - @padding_right,
        height: @height - @padding_top - @padding_bottom,
        mode: mode,
        cursor: cursor,
        direction: @direction,
        looped: looped
      )
    end

    # Create the scrollbar with the given parameters. Do nothing if parameters are nil
    # @param scrollbar_params [Hash] the parameters
    # @author Leikt
    def create_scrollbar(scrollbar_params)
      return unless scrollbar_params

      @scrollbar = ScrollBar.new(
        @viewport,
        @content,
        scrollbar_params
      )
    end

    # Retrieve the item parameters from a hash
    # @param hash [Hash, nil] the custom parameters
    # @return [Hash]
    def retrieve_item_params(hash)
      hash ||= {}
      hash[:list_width] = @width - @padding_left - @padding_right unless hash[:width]
      hash[:list_height] = @height - @padding_bottom - @padding_top unless hash[:height]
      hash[:list_direction] = @direction
      return hash
    end

    # Retrieve the scrollbar params from the content
    # @param hash [Hash] the existing parameters
    # @return [Hash]
    def retrieve_scrollbar_param(hash)
      if hash
        hash[:max] = @content.max_origin
        hash[:min] = @content.min_origin
        hash[:direction] = @direction
      end
      return hash
    end
  end
end

# HERE IS AN EXEMPLE OF HOW TO USE LIST

# module GamePlay
#   class UI_Test < Base
#     def initialize
#       super
#       @viewport = Viewport.create(:main, @message_window.z - 1)
#       # @viewport = Viewport.create(0, 10, 400, 400, 50_000)

#       # Liste des pokemons
#       list = []
#       1.upto(150) do |i|
#         list.push PFM::Pokemon.new(rand(1..666), i)
#       end

#       @ui_list = UI::List.new(
#         @viewport,
#         x: 5, y: 5,
#         width: 250, height: 55,
#         padding_left: 4, padding_right: 4,
#         padding_top: 4, padding_bottom: 17,
#         items: list,
#         item_type: UI::List::ListItem::ColumnPokemonIcon,
#         index: 8,
#         mode: :center_clamped,
#         cursor: 'selector',
#         direction: :horizontal,
#         scrollbar: {
#           size: 125,
#           skin: 'scrollbar_psdk',
#           offset: -50
#         }
#       )

#       # List des objects
#       item_list_1 = []
#       item_list_2 = []
#       1.upto(150) do |i|
#         item_list_1.push [rand(1..500), i]
#         item_list_2.push PFM::Pokemon.new(i, 1)
#       end
#       @ui_item_1 = [item_list_1, UI::List::ListItem::LineItem, nil]
#       @ui_item_2 = [item_list_2, UI::List::ListItem::ColumnPokemonIcon, nil]

#       coord_mod = proc do |item, hash|
#         # Retrieve variables
#         mo = 20.0
#         list_length = hash[:list_length].to_f
#         item_size = hash[:item_size].to_f
#         rel_y = hash[:rel_y] - hash[:viewport_dy]
#         # Init bound
#         my = ((list_length - 1.0) / 2.0) * item_size
#         ey = (list_length - 1.0) * item_size
#         # Calculate value
#         if rel_y < my
#           item.x += (rel_y * (mo / my)).to_i
#         else
#           item.x += (rel_y * - (mo / (ey - my)) + 2 * mo).to_i
#         end
#       end

#       @ui_list_items = UI::List.new(
#         @viewport,
#         x: 5, y: 88,
#         width: 250, height: 150,
#         padding_left: 4, padding_right: 10,
#         padding_top: 4, padding_bottom: 4,
#         items: item_list_1,
#         item_type: UI::List::ListItem::LineItem,
#         index: 0,
#         mode: :center,
#         cursor: 'selector',
#         direction: :vertical,
#         item_params: { modifier: coord_mod },
#         scrollbar: { skin: 'scrollbar_psdk', size: 138, offset: 2 },
#         looped: true
#       )

#       # Icone de selection
#       UI::Window.new(@viewport, 260, 5, 32, 32)
#       @pkm_display = UI::PokemonIconSprite.new(@viewport)
#       @pkm_display.set_position(276, 18)

#       UI::Window.new(@viewport, 260, 38, 32, 32)
#       @item_display = UI::ItemSprite.new(@viewport)
#       @item_display.set_position(260, 38)

#       # Liste tris
#       @sort_proc = {
#         'Name' => proc { |a, b| GameData::Item.name(a[0]) <=> GameData::Item.name(b[0]) },
#         'Count' => proc { |a,b| a[1] <=> b[1] },
#         'Value' => proc { |a, b| GameData::Item.price(a[0]) <=> GameData::Item.price(b[0]) },
#         'None' => nil
#       }
#       @ui_list_sort = UI::List.new(
#         @viewport,
#         x: 260, y: 75,
#         width: 60, height: @sort_proc.length * 20 + 8,
#         padding_left: 4, padding_right: 4,
#         padding_top: 4, padding_bottom: 4,
#         items: @sort_proc.keys,
#         item_type: UI::List::ListItem::SimpleText,
#         index: @sort_proc.length - 1,
#         mode: :center_clamped,
#         cursor: 'selector',
#         direction: :vertical
#       )

#       # Sort the item list
#       @ui_list_items.sort(@sort_proc['None'])

#       @search_bar = UI::TextInput.new(
#         0, @viewport, 5, 65, 250, 28, '',
#         padding_left: 8, padding_top: 4,
#         padding_bottom: 4, padding_right: 4
#       )
#     end

#     def update
#       update_graphics
#       return unless super

#       update_inputs
#     end

#     def update_graphics
#       @ui_list&.update
#       @ui_list_items&.update
#       @ui_list_sort&.update
#     end

#     def update_inputs
#       @search_bar.update

#       if @search_bar.activated
#         if @search_bar.modified?
#           text = @search_bar.text.downcase
#           block = proc { |a| GameData::Item.name(a[0]).downcase.include?(text) }
#           block = nil if text.empty?
#           @ui_list_items.filter = block
#         end
#       else
#         return classic_input
#       end
#     end

#     def classic_input
#       @running = false if Input.trigger?(:B)

#       if Input.press?(:down)
#         @ui_list_items&.index = @ui_list_items.index + 1
#       elsif Input.press?(:up)
#         @ui_list_items&.index = @ui_list_items.index - 1
#       elsif Input.press?(:left)
#         @ui_list&.index = @ui_list.index - 1
#       elsif Input.press?(:right)
#         @ui_list&.index = @ui_list.index + 1
#       elsif Input.trigger?(:c)
#         if @ui_list&.simple_mouse_in?
#           d = @ui_list&.selected
#           @pkm_display.data = d if d
#         end
#         if @ui_list_items&.simple_mouse_in?
#           d = @ui_list_items&.selected
#           @item_display.data = d[0] if d
#         end
#         if @ui_list_sort&.simple_mouse_in?
#           sort = @ui_list_sort.selected
#           @ui_list_items.sort(@sort_proc[sort]) if sort
#         end
#       elsif Mouse.trigger?(:left)
#         if @ui_list&.simple_mouse_in?
#           d = @ui_list&.selected(true)
#           @pkm_display.data = d if d
#         end
#         if @ui_list_items&.simple_mouse_in?
#           d = @ui_list_items&.selected(true)
#           @item_display.data = d[0] if d
#         end
#         if @ui_list_sort&.simple_mouse_in?
#           sort = @ui_list_sort.selected(true)
#           @ui_list_items.sort(@sort_proc[sort]) if sort
#         end
#       elsif Input.trigger?(:Y)
#         @ui_list_items.setup(*(@ui_list_items.data == @ui_item_1[0] ? @ui_item_2 : @ui_item_1))
#       end
#     end

#     def dispose
#       super
#       @ui_list&.dispose
#       @ui_list_items&.dispose
#       @ui_list_sort&.dispose
#     end
#   end
# end
