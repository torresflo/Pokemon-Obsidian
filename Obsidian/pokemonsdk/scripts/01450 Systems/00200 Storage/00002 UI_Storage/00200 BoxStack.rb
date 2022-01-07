module UI
  module Storage
    # Stack responsive of showing a box
    class BoxStack < UI::SpriteStack
      # Get the current mode
      # @return [Symbol]
      attr_reader :mode
      # Create a new box stack
      # @param viewport [Viewport]
      # @param mode_handler [ModeHandler] object responsive of handling the mode
      # @param selection_handler [SelectionHandler] object responsive of handling the selection
      def initialize(viewport, mode_handler, selection_handler)
        super(viewport)
        @selection = []
        create_stack
        mode_handler.add_mode_ui(self)
        selection_handler.box_selection_display = self
      end

      # Tell if the name background is hovered in order to show the option menu
      # @return [Boolean]
      def box_option_hovered?
        return @name_background.simple_mouse_in?
      end

      # Update the selection
      # @param selection [Array<Integer>] list of selected indexes
      def update_selection(selection)
        @select_buttons.each_with_index do |button, index|
          button.visible = selected = selection.include?(index)
          @pokemon_icons[index].y = @pokemon_shadows[index].y - (selected ? 4 : 0)
        end
        @selection = selection
      end

      # Update the data
      # @param data [PFM::Storage::Box]
      def data=(data)
        super
        self.mode = @mode
        update_selection(@selection)
      end

      # Make the pokemon gray depending on a criteria
      # @yieldparam pokemon [PFM::Pokemon]
      def gray_pokemon
        @pokemon_icons.each_with_index do |icon, index|
          pokemon = @data.content[index]
          icon.shader = (pokemon && yield(pokemon) ? @gray_shader : nil)
        end
      end

      # Set the mode
      # @param mode [Symbol]
      def mode=(mode)
        mode == :item ? update_sprites_to_item : update_sprites_to_other
        @mode = mode
      end

      # Get the Pokemon sprites
      # @return [Array<Sprite>]
      def pokemon_sprites
        @pokemon_shadows
      end

      private

      def create_stack
        create_box_background
        create_box_name_background
        create_box_name
        create_slots
        create_select_button
        create_pokemons
      end

      def create_box_background
        push_sprite(BoxBackground.new(@viewport))
      end

      def create_box_name_background
        add_sprite(15, 22, 'pc/name_frame')
        # @type [BoxNameBackground]
        @name_background = add_sprite(20, 27, NO_INITIAL_IMAGE, type: BoxNameBackground).set_z(3)
      end

      def create_box_name
        add_text(20, 27, 108, 17, :name, 1, type: SymText, color: 9).z = 4
      end

      def create_slots
        add_sprite(10, 56, 'pc/slots').set_z(2)
      end

      def create_select_button
        bmp = RPG::Cache.interface('pc/select')
        @select_buttons = Array.new(PFM.storage_class.box_size) do |i|
          sprite = add_sprite(7 + 32 * (i % 6), 53 + 32 * (i / 6), bmp).set_z(3)
          sprite.visible = false
          next sprite
        end
      end

      def create_pokemons
        shadow_shader = Shader.create(:color_shader)
        shadow_shader.set_float_uniform('color', Color.new(57, 59, 67))
        @gray_shader = Shader.create(:tone_shader)
        @gray_shader.set_float_uniform('tone', Tone.new(0, 0, 0, 255))
        pokemon_count = PFM.storage_class.box_size
        @pokemon_shadows = Array.new(pokemon_count) do |i|
          sprite = add_sprite(8 + 32 * (i % 6), 54 + 32 * (i / 6), NO_INITIAL_IMAGE, i, type: PokemonIcon).set_z(4)
          sprite.shader = shadow_shader
          next sprite
        end
        @pokemon_icons = Array.new(pokemon_count) do |i|
          sprite = add_sprite(8 + 32 * (i % 6), 54 + 32 * (i / 6), NO_INITIAL_IMAGE, i, type: PokemonIcon).set_z(4)
          next sprite
        end
        @pokemon_items = Array.new(pokemon_count) do |i|
          sprite = add_sprite(8 + 32 * (i % 6), 54 + 32 * (i / 6), NO_INITIAL_IMAGE, i, type: PokemonItemIcon).set_z(4)
          next sprite
        end
      end

      # Update sprites to item mode
      def update_sprites_to_item
        @pokemon_items.each { |i| i.opacity = 255 }
        @pokemon_icons.each_with_index do |s, i|
          s.opacity = 128
          s.shader = @pokemon_items[i].visible ? nil : @gray_shader
        end
      end

      # Update sprites to other modes
      def update_sprites_to_other
        @pokemon_items.each { |i| i.opacity = 0 }
        @pokemon_icons.each do |i|
          i.opacity = 255
          i.shader = nil
        end
      end
    end
  end
end
