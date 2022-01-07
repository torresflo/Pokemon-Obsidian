module UI
  module Storage
    # Stack responsive of showing a party
    class PartyStack < UI::SpriteStack
      # Get the current mode
      # @return [Symbol]
      attr_reader :mode
      # List of images according to the mode
      SLOT_IMAGES = { pokemon: 'pc/party_pkmn', item: 'pc/party_items', battle: 'pc/party_battle' }
      # List of coordinate for Pokemon sprite
      POKEMON_COORDINATES = [
        [224, 64], [272, 80],
        [224, 112], [272, 128],
        [224, 160], [272, 176]
      ]
      # Create a new party stack
      # @param viewport [Viewport]
      # @param mode_handler [ModeHandler] object responsive of handling the mode
      # @param selection_handler [SelectionHandler] object responsive of handling the selection
      def initialize(viewport, mode_handler, selection_handler)
        super(viewport)
        create_stack
        mode_handler.add_mode_ui(self)
        selection_handler.party_selection_display = self
        @selection = []
      end

      # Update the selection
      # @param selection [Array<Integer>] current selected Pokemon
      def update_selection(selection)
        @select_buttons.each_with_index do |button, index|
          button.visible = selected = selection.include?(index)
          @pokemon_icons[index].y = @pokemon_shadows[index].y - (selected ? 4 : 0)
        end
        @selection = selection
      end

      # Update the data
      # @param data [PFM::Storage::BattleBox]
      def data=(data)
        super
        update_selection(@selection)
        self.mode = @mode
        @box_name.visible = @mode == :battle
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
        @slots.set_bitmap(SLOT_IMAGES[mode], :interface) if (@slots.visible = mode != :box)
        @box_name.visible = @left_arrow.visible = @right_arrow.visible = mode == :battle
        @txt_party.visible = !@box_name.visible
      end

      # Get the Pokemon sprites
      # @return [Array<Sprite>]
      def pokemon_sprites
        @pokemon_shadows
      end

      # Tell if the left arrow is hovered
      # @return [Boolean]
      def hovering_left_arrow?
        @left_arrow.simple_mouse_in?
      end

      # Tell if the right arrow is hovered
      # @return [Boolean]
      def hovering_right_arrow?
        @right_arrow.simple_mouse_in?
      end

      private

      def create_stack
        create_txt_party
        create_box_name
        create_slots
        create_select_button
        create_pokemons
        create_arrows
      end

      def create_txt_party
        @txt_party = add_sprite(234, 37, 'pc/txt_party_').set_z(2)
      end

      def create_box_name
        @box_name = add_text(226, 37, 75, 16, :name, 1, 1, type: UI::SymText, color: 10)
        @box_name.z = 2
        @box_name.bold = true
      end

      def create_slots
        @slots = add_sprite(221, 61, NO_INITIAL_IMAGE).set_z(2)
      end

      def create_select_button
        bmp = RPG::Cache.interface('pc/select')
        @select_buttons = Array.new(6) do |i|
          x, y = POKEMON_COORDINATES[i]
          sprite = add_sprite(x - 1, y - 1, bmp).set_z(3)
          sprite.visible = false
          next sprite
        end
      end

      def create_pokemons
        shadow_shader = Shader.create(:color_shader)
        shadow_shader.set_float_uniform('color', Color.new(57, 59, 67))
        @gray_shader = Shader.create(:tone_shader)
        @gray_shader.set_float_uniform('tone', Tone.new(0, 0, 0, 255))
        pokemon_count = 6
        @pokemon_shadows = Array.new(pokemon_count) do |i|
          sprite = add_sprite(*POKEMON_COORDINATES[i], NO_INITIAL_IMAGE, i, type: PokemonIcon).set_z(4)
          sprite.shader = shadow_shader
          next sprite
        end
        @pokemon_icons = Array.new(pokemon_count) do |i|
          sprite = add_sprite(*POKEMON_COORDINATES[i], NO_INITIAL_IMAGE, i, type: PokemonIcon).set_z(4)
          next sprite
        end
        @pokemon_items = Array.new(pokemon_count) do |i|
          sprite = add_sprite(*POKEMON_COORDINATES[i], NO_INITIAL_IMAGE, i, type: PokemonItemIcon).set_z(4)
          next sprite
        end
      end

      def create_arrows
        @left_arrow = add_sprite(214, 38, NO_INITIAL_IMAGE, :L, type: UI::KeyShortcut).set_z(2)
        @right_arrow = add_sprite(301, 38, NO_INITIAL_IMAGE, :R, type: UI::KeyShortcut).set_z(2)
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
