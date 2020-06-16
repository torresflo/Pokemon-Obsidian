module GamePlay
  # Scene showing the Egg of a Pokemon hatching
  class Hatch < Base
    # Move duration
    EGG_MOVE_DURATION = 180
    # Move period
    EGG_MOVE_PERIOD = 60
    # Move angle
    EGG_MOVE_ANGLE = 10
    # Max red component of the Viewport's tone when the egg is glowing
    TONE_RED_MAX = 255 / 5
    # Max green component of the Viewport's tone when the egg is glowing
    TONE_GREEN_MAX = 180 / 5
    # Time when the egg starts to glow
    EGG_GLOW_START = EGG_MOVE_DURATION + 1
    # Time when the egg stops to glow
    EGG_GLOW_END = EGG_GLOW_START + 180
    # The factor used in the glow alpha
    EGG_GLOW_FACTOR = 255
    # Time when the viewport start to show the tone when the egg is glowing
    VIEWPORT_GLOW_START = EGG_GLOW_START + 30
    # Time when the viewport finish to show the tone when the egg is glowing
    VIEWPORT_GLOW_END = EGG_GLOW_END - 30
    # Time when the flash starts (pokemon shown, egg hidden)
    FLASH_START = EGG_GLOW_END + 1
    # Time when the flash ends
    FLASH_END = FLASH_START + 20
    # Time when the Pokemon starts to decrease it's color alpha
    POKEMON_ALPHA_DOWN_START = FLASH_START + 30
    # Time when the Pokemon ends to decrease it's color alpha
    POKEMON_ALPHA_DOWN_END = POKEMON_ALPHA_DOWN_START + 40
    # Max alpha of the Pokemon color
    MAX_POKEMON_ALPHA = 230
    # Name of the move file
    EGG_MOVE_SE = 'audio/se/pokemove.wav'

    include Math

    # Create a new Hatch scene
    def initialize(pkmn)
      super()
      @pokemon = pkmn
      @egg = pkmn.clone
      @egg.step_remaining = 1
      @counter = 0
      play_music
    end

    # Update the hatching process
    def update
      # Prevent animation from continuing when message is showing
      return unless super
      update_message
      update_animation
      @counter += 1
    end

    private

    # Play the evolve music
    def play_music
      $game_system.bgm_memorize2
      Audio.bgm_stop
      Audio.bgm_play(Evolve::EVOLVE_MUSIC)
    end

    # Update the message to show according to the counter
    def update_message
      # Show the "What?" message
      if @counter == 0
        @message_window.auto_skip = true
        @message_window.stay_visible = true
        display_message(text_get(36, 37))
      elsif @counter == POKEMON_ALPHA_DOWN_END
        @message_window.auto_skip = false
        Audio.bgm_play(Evolve::EVOLVED_MUSIC)
        PFM::Text.set_pkname(@pokemon, 0)
        display_message(text_get(36, 38))
      elsif @counter > POKEMON_ALPHA_DOWN_END
        show_rename_choice
        Audio.bgm_stop
        $game_system.bgm_restore2
        $pokedex.mark_seen(@pokemon.id, @pokemon.form, forced: true)
        $pokedex.mark_captured(@pokemon.id)
        $pokedex.pokemon_fought_inc(@pokemon.id)
        $pokedex.pokemon_captured_inc(@pokemon.id)
        @running = false
      end
    end

    # Show the rename choice
    def show_rename_choice
      PFM::Text.set_pkname(@pokemon, 0)
      choice = display_message(text_get(36, 39), 1, text_get(11, 27), text_get(11, 28))
      return unless choice == 0 # No
      Graphics.freeze
      @pokemon.given_name = GamePlay::NameInput.new(@pokemon.given_name, 12, @pokemon).main.return_name
    end

    # Update the animation
    def update_animation
      update_egg_move if @counter <= EGG_MOVE_DURATION
      update_egg_glow if @counter.between?(EGG_GLOW_START, EGG_GLOW_END)
      update_viewport_glow if @counter.between?(VIEWPORT_GLOW_START, VIEWPORT_GLOW_END)
      update_viewport_flash if @counter.between?(FLASH_START, FLASH_END)
      switch_sprites if @counter == FLASH_START
      update_pokemon_alpha_down if @counter.between?(POKEMON_ALPHA_DOWN_START, POKEMON_ALPHA_DOWN_END)
    end

    # Update the egg move
    def update_egg_move
      @egg_sprite.angle = EGG_MOVE_ANGLE * sin(@counter * PI / EGG_MOVE_PERIOD)**17
      return unless ((@counter + EGG_MOVE_PERIOD / 2) % EGG_MOVE_PERIOD) == 0
      Audio.se_play(EGG_MOVE_SE)
    end

    # Update the egg glow animation
    def update_egg_glow
      glow_max = EGG_GLOW_END - EGG_GLOW_START
      @egg_color.alpha = (@counter - EGG_GLOW_START) * EGG_GLOW_FACTOR / glow_max if glow_max != 0
      @egg_sprite.set_color(@egg_color)
    end

    # Update the viewport glow animation
    def update_viewport_glow
      current_viewport_time = @counter - VIEWPORT_GLOW_START
      max_viewport_time = VIEWPORT_GLOW_END - VIEWPORT_GLOW_START
      @viewport.tone.set(
        TONE_RED_MAX * current_viewport_time / max_viewport_time,
        TONE_GREEN_MAX * current_viewport_time / max_viewport_time,
        0, 0
      )
    end

    # Switch the sprite before the flash process
    def switch_sprites
      @viewport.tone.set(0, 0, 0, 0)
      @egg_sprite.visible = false
      @pokemon_sprite.visible = true
    end

    # Update the viewport flash animation
    def update_viewport_flash
      max_viewport_flash_time = FLASH_END - FLASH_START
      current_viewport_flash_time = max_viewport_flash_time - (@counter - FLASH_START)
      @viewport.color.set(255, 255, 255, 255 * current_viewport_flash_time / max_viewport_flash_time)
    end

    # Update the Pokemon alpha down animation
    def update_pokemon_alpha_down
      max_alpha_time = POKEMON_ALPHA_DOWN_END - POKEMON_ALPHA_DOWN_START
      current_time = max_alpha_time - (@counter - POKEMON_ALPHA_DOWN_START)
      @pokemon_color.alpha = MAX_POKEMON_ALPHA * current_time / max_alpha_time
      @pokemon_sprite.set_color(@pokemon_color)
    end

    # Create the background
    def create_background
      id_bg = $env.get_zone_type(true)
      if id_bg == 0
        id_bg = 1 if $env.grass?
      else
        id_bg += 1
      end
      @background = Sprite.new(@viewport).set_bitmap(Evolve::BACK_NAMES[id_bg], :battleback)
    end

    # Create the Pokemon sprite
    def create_pokemon_sprite
      @pokemon_sprite = Sprite::WithColor.new(@viewport).set_bitmap(@pokemon.battler_face)
      @pokemon_sprite.set_position(@viewport.rect.width / 2, @viewport.rect.height / 2)
      @pokemon_sprite.set_origin_div(2, 1)
      @pokemon_sprite.set_color(@pokemon_color = Color.new(255, 255, 255, MAX_POKEMON_ALPHA))
      @pokemon_sprite.visible = false
    end

    # Create the egg sprite
    def create_egg_sprite
      @egg_sprite = Sprite::WithColor.new(@viewport).set_bitmap(@egg.battler_face)
      @egg_sprite.set_position(@viewport.rect.width / 2, @viewport.rect.height / 2)
      @egg_sprite.set_origin_div(2, 1)
      @egg_sprite.set_color(@egg_color = Color.new(255, 180, 0, 0))
    end

    # Create the scene graphics
    def create_graphics
      create_viewport
      create_background
      create_pokemon_sprite
      create_egg_sprite
    end

    # Create the scene viewport
    def create_viewport
      @viewport = Viewport.create(:main, @message_window.z - 1)
    end
  end
end
