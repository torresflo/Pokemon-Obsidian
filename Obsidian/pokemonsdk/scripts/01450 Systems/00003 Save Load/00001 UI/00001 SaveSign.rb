module UI
  # UI element showing the save information
  class SaveSign < SpriteStack
    # Get the index of the save
    # @return [Integer]
    attr_accessor :save_index
    # Get the visual index of the save sign
    # @return [Integer]
    attr_accessor :visual_index

    # String shown when a save is corrupted
    CORRUPTED_MESSAGE = 'Corrupted Save File'
    # String shown when a save is not corrupted and can be choosen
    SAVE_INDEX_MESSAGE = 'Save %d'

    # Create a new save sign
    # @param viewport [Viewport]
    # @param visual_index [Integer]
    def initialize(viewport, visual_index)
      super(viewport, *coordinates(visual_index))
      create_sprites
      @save_index = 0
      @visual_index = visual_index
    end

    # Set the data of the SaveSign
    # @param value [PFM::Pokemon_Party, Symbol] :new if new game, :corrupted if corrupted
    def data=(value)
      @data = value
      self.visible = true
      case value
      when :new
        show_new_game
      when :corrupted
        show_corrupted
      when :hidden
        self.visible = false
      else
        show_data(value)
      end
      @cursor&.visible = @visual_index == 0
    end

    # Update the animation
    def update
      super
      @animation&.update
    end

    # Tell if the animation is done
    # @return [Boolean]
    def done?
      return true unless @animation

      return @animation.done?
    end

    # Start the animation of moving between index
    # @param target_visual_index [Integer]
    def move_to_visual_index(target_visual_index)
      real_visual_index = @visual_index == -1 && target_visual_index == 3 ? -2 : target_visual_index
      real_visual_index = @visual_index == 3 && real_visual_index == -1 ? 4 : real_visual_index
      @cursor.visible = false
      @animation = Yuki::Animation.move_discreet(0.1, self, *coordinates(@visual_index), *coordinates(real_visual_index))
      @animation.play_before(Yuki::Animation.send_command_to(self, :set_position, *coordinates(target_visual_index)))
      @animation.play_before(Yuki::Animation.send_command_to(self, :animate_cursor)) if target_visual_index == 0
      @animation.start
      @visual_index = target_visual_index
    end

    def animate_cursor
      @cursor.visible = true
      @animation = Yuki::Animation::TimedLoopAnimation.new(1)
      @animation.play_before(Yuki::Animation.wait(1))
      parallel = Yuki::Animation.send_command_to(@cursor, :sy=, 0)
      parallel.play_before(Yuki::Animation.wait(0.5))
      parallel.play_before(Yuki::Animation.send_command_to(@cursor, :sy=, 1))
      @animation.parallel_add(parallel)
      @animation.start
    end

    # Get the coordinate of the element based on its coordinate
    # @param visual_index [Integer] visual index of the UI element
    # @return [Array<Integer>]
    def coordinates(visual_index)
      return [base_x + visual_index * spacing_x, base_y + visual_index * spacing_y]
    end

    private

    def show_new_game
      @swap_sprites.each { |sp| sp.visible = false }
      @background.load('load/box_new', :interface)
      @cursor.load('load/cursor_corrupted_new', :interface)
      @new_corrupted_text.text = ext_text(9000, 0)
    end

    def show_corrupted
      @swap_sprites.each { |sp| sp.visible = false }
      @background.load('load/box_corrupted', :interface)
      @cursor.load('load/cursor_corrupted_new', :interface)
      @new_corrupted_text.text = corrupted_message
    end

    # Show the save data
    # @param value [PFM::Pokemon_Party]
    def show_data(value)
      @swap_sprites.each { |sp| sp.visible = true }
      @background.load('load/box_main', :interface)
      @cursor.load('load/cursor_main', :interface)
      @save_text.text = format(save_index_message, @save_index)
      @new_corrupted_text.visible = false
      show_save_data(value)
    end

    # Show the save data
    # @param value [PFM::Pokemon_Party]
    def show_save_data(value)
      @player_sprite.load(value.game_player.character_name, :character)
      @player_sprite.set_origin(@player_sprite.width / 2, @player_sprite.height)
      @location_text.text = value.env.current_zone_name
      @player_name.text = value.trainer.name
      @badge_value&.text = value.trainer.badge_counter.to_s
      @pokedex_value&.text = value.pokedex.pokemon_seen.to_s
      @time_value&.text = value.trainer.play_time_text
      @pokemon_sprites.each_with_index do |sprite, index|
        sprite.data = value.actors[index]
      end
    end

    def create_sprites
      @swap_sprites = []
      create_background
      create_cursor
      create_player_sprite
      create_player_name
      create_save_text
      create_save_info_text
      create_pokemon_sprites
    end

    def create_background
      @background = add_sprite(0, 0, NO_INITIAL_IMAGE)
    end

    def create_cursor
      @cursor = add_sprite(-4, -4, NO_INITIAL_IMAGE, 1, 2, type: SpriteSheet)
    end

    def create_player_sprite
      @player_sprite = add_sprite(44, 62, NO_INITIAL_IMAGE, 4, 4, type: SpriteSheet)
      @swap_sprites << @player_sprite
    end

    def create_player_name
      @player_name = add_text(45, 63, 0, 16, '', 1, color: player_name_color)
      @swap_sprites << @player_name
    end

    def create_save_text
      @save_text = add_text(0, 1, 226, 16, '', 1)
      @new_corrupted_text = add_text(0, 4, 226, 16, '', 1, color: 10)
      @swap_sprites << @save_text
    end

    def create_save_info_text
      @location_text = add_text(91, 19, 0, 16, '', color: location_color)
      @swap_sprites << @location_text
      @badge_text = add_text(91, 35, 0, 16, text_get(25, 1), color: info_color)
      @swap_sprites << @badge_text
      @badge_value = add_text(216, 35, 0, 16, '', 2, color: info_color)
      @swap_sprites << @badge_value
      @pokedex_text = add_text(91, 51, 0, 16, text_get(25, 3), color: info_color)
      @swap_sprites << @pokedex_text
      @pokedex_value = add_text(216, 51, 0, 16, '', 2, color: info_color)
      @swap_sprites << @pokedex_value
      @time_text = add_text(91, 67, 0, 16, text_get(25, 5), color: info_color)
      @swap_sprites << @time_text
      @time_value = add_text(216, 67, 0, 16, '', 2, color: info_color)
      @swap_sprites << @time_value
    end

    def create_pokemon_sprites
      @pokemon_sprites = Array.new(6) { |i| add_sprite(24 + i * 35, 99, NO_INITIAL_IMAGE, type: PokemonIconSprite) }
      @swap_sprites.concat(@pokemon_sprites)
    end

    def player_name_color
      9
    end

    def location_color
      0
    end

    def info_color
      26
    end

    def corrupted_message
      CORRUPTED_MESSAGE
    end

    def save_index_message
      SAVE_INDEX_MESSAGE
    end

    def base_x
      47
    end

    def base_y
      51
    end

    def spacing_x
      240
    end

    def spacing_y
      0
    end
  end
end
