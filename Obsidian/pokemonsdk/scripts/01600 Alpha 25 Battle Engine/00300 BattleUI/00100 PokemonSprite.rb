# Module that hold all the Battle UI elements
module BattleUI
  # Sprite of a Pokemon in the battle
  class PokemonSprite < ShaderedSprite
    # @return [Boolean] if the sprite is currently selected
    attr_accessor :selected
    # @return [PFM::PokemonBattler] the Pokemon shown by the sprite
    attr_reader :pokemon
    # @return [Proc] the current animation on the sprite
    attr_reader :animation

    # Update the sprite
    def update
      return unless prior_update_check
      update_selected_animation if @selected
      @gif&.update(bitmap)
      @animation&.call
    end

    # Set the Pokemon
    # @param pokemon [PFM::PokemonBattler]
    def pokemon=(pokemon)
      @pokemon = pokemon
      if pokemon
        load_battler
        reset_position
      end
    end

    # Return if the sprite is still animated
    def animated?
      !@animation.nil?
    end

    # Return if the animation is done
    def done?
      @animation.nil?
    end

    # Dispose the sprite
    def dispose
      if @gif
        remove_instance_variable(:@gif)
        bitmap.dispose
      end
      super
    end

    # Start the KO animation
    def start_animation_KO
      cry(true)
      @animation = proc do
        src_rect.height -= 2
        self.y += 2
        self.opacity -= 15
        if opacity <= 0
          @animation = nil
          reset_position
          src_rect.height = bitmap.height
        end
      end
    end

    # Start the going out (of ball) Animation
    def start_animation_going_out
      self.zoom = 0
      reset_position
      @animation = proc do
        self.zoom = zoom_x + 0.1
        if zoom_x >= 1
          cry
          @animation = nil
          self.zoom = 1
        end
      end
    end

    # Start the going in (ball) Animation
    def start_animation_going_in
      self.zoom = 1
      reset_position
      @animation = proc do
        self.zoom = zoom_x - 0.1
        if zoom_x <= 0
          @animation = nil
          self.zoom = 0
        end
      end
    end

    # Play the cry of the Pokemon
    # @param dying [Boolean] if the Pokemon is dying
    def cry(dying = false)
      return unless @pokemon
      Audio.se_play(@pokemon.cry, 100, dying ? 80 : 100)
    end

    # Reset the battler position
    def reset_position
      set_position(basic_x_position, basic_y_position)
      self.z = basic_z_position
      self.ox = width / 2
      self.oy = height
    end

    # Affect the zoom property
    # @param value [Numeric] the new zoom
    def zoom=(value)
      super(@pokemon&.bank == 0 ? 2 * value : value)
    end

    # Return the zoom_x value
    # @return [Numeric]
    def zoom_x
      @pokemon&.bank == 0 ? super / 2 : super
    end

    alias zoom_y zoom_x

    private

    # Return the basic x position
    # @return [Integer]
    def basic_x_position
      # @pokemon.bank == 0 means the Pokemon is in the actor bank
      x = @pokemon.bank == 0 ? 88 : 233
      # We adjust the position if we're in a multi-battle
      x -= (@pokemon.bank == 0 ? 48 : 24) if $game_temp.vs_type != 1
      x += @pokemon.position * (@pokemon.bank == 0 ? 96 : 48)
      return x
    end

    # Return the basic y position
    # @return [Integer]
    def basic_y_position
      # @pokemon.bank == 0 means the Pokemon is in the actor bank
      y = @pokemon.bank == 0 ? 202 : 94
      y += offset_y
      if $game_temp.vs_type != 1
        y -= @pokemon.bank == 0 ? 0 : 4
        y += @pokemon.position * (@pokemon.bank == 0 ? 16 : 8)
      end
      return y
    end

    # Return the offset_y of the battler
    # @return [Integer]
    def offset_y
      0
    end

    # Return the basic z position of the battler
    def basic_z_position
      z = @pokemon.bank == 0 ? 501 : 1
      z += @pokemon.position
      return z
    end

    # Update the selected animation
    def update_selected_animation
      @selected_counter = @selected_counter.to_i + 1
      self.y = basic_y_position + (@selected_counter / 20 % 2)
      @selected_counter = 0 if @selected_counter >= 40 # 2 * 20
    end

    # Function that check prior thing before allowing the sprite to update
    # @return [Boolean] if update can continue
    def prior_update_check
      unless @pokemon
        self.visible = false if visible
        return false
      end
      self.visible = true unless visible
      return true
    end

    # Load the battler of the Pokemon
    def load_battler
      if @last_pokemon&.id != @pokemon.id || @last_pokemon&.form != @pokemon.form
        bitmap.dispose if @gif
        remove_instance_variable(:@gif) if instance_variable_defined?(:@gif)
        gif = pokemon.bank != 0 ? pokemon.gif_face : pokemon.gif_back
        if gif
          @gif = gif
          self.bitmap = Bitmap.new(gif.width, gif.height)
          gif.draw(bitmap)
        else
          self.bitmap = pokemon.bank != 0 ? pokemon.battler_face : pokemon.battler_back
        end
      end
      @last_pokemon = @pokemon
    end
  end
end
