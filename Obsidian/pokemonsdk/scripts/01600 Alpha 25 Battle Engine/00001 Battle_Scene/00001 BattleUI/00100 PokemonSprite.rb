module BattleUI
  # Sprite of a Pokemon in the battle
  class PokemonSprite < ShaderedSprite
    include GoingInOut
    include MultiplePosition
    # Constant giving the deat Delta Y (you need to adjust that so your screen animation are OK when Pokemon are KO)
    DELTA_DEATH_Y = 32
    # Tell if the sprite is currently selected
    # @return [Boolean]
    attr_accessor :selected
    # Get the Pokemon shown by the sprite
    # @return [PFM::PokemonBattler]
    attr_reader :pokemon
    # Get the animation handler
    # @return [Yuki::Animation::Handler{ Symbol => Yuki::Animation::TimedAnimation}]
    attr_reader :animation_handler
    # Get the position of the pokemon shown by the sprite
    # @return [Integer]
    attr_reader :position
    # Get the bank of the pokemon shown by the sprite
    # @return [Integer]
    attr_reader :bank
    # Get the scene linked to this object
    # @return [Battle::Scene]
    attr_reader :scene

    # Create a new PokemonSprite
    # @param viewport [Viewport]
    # @param scene [Battle::Scene]
    def initialize(viewport, scene)
      super(viewport)
      @shadow = ShaderedSprite.new(viewport)
      @shadow.shader = Shader.create(:battle_shadow)
      @animation_handler = Yuki::Animation::Handler.new
      @bank = 0
      @position = 0
      @scene = scene
    end

    # Update the sprite
    def update
      @animation_handler.update
      @gif&.update(bitmap) unless pokemon&.dead?
    end

    # Tell if the sprite animations are done
    # @return [Boolean]
    def done?
      return @animation_handler.done?
    end

    # Set the Pokemon
    # @param pokemon [PFM::PokemonBattler]
    def pokemon=(pokemon)
      @pokemon = pokemon
      if pokemon
        @position = pokemon.position
        @bank = pokemon.bank
        load_battler
        reset_position
      end
    end

    # Play the cry of the Pokemon
    # @param dying [Boolean] if the Pokemon is dying
    def cry(dying = false)
      return unless pokemon

      Audio.se_play(pokemon.cry, 100, dying ? 80 : 100)
    end

    # Set the origin of the sprite & the shadow
    # @param ox [Numeric]
    # @param oy [Numeric]
    # @return [self]
    def set_origin(ox, oy)
      @shadow.set_origin(ox, oy)
      super
    end

    # Set the zoom of the sprite
    # @param zoom [Float]
    def zoom=(zoom)
      @shadow.zoom = zoom
      super
    end

    # Set the position of the sprite
    # @param x [Numeric]
    # @param y [Numeric]
    # @return [self]
    def set_position(x, y)
      @shadow.set_position(x, y)
      super
    end

    # Set the y position of the sprite
    # @param y [Numeric]
    def y=(y)
      @shadow.y = y
      super
    end

    # Set the x position of the sprite
    # @param x [Numeric]
    def x=(x)
      @shadow.x = x
      super
    end

    # Set the opacity of the sprite
    # @param opacity [Integer]
    def opacity=(opacity)
      @shadow.opacity = opacity
      super
    end

    # Set the bitmap of the sprite
    # @param bitmap [Texture]
    def bitmap=(bitmap)
      @shadow.bitmap = bitmap
      super
    end

    # Set the visibility of the sprite
    # @param visible [Boolean]
    def visible=(visible)
      @shadow.visible = visible
      super
    end

    # Creates the flee animation
    # @return [Yuki::Animation::TimedAnimation]
    def flee_animation
      bx = enemy? ? viewport.rect.width + width : -width
      ya = Yuki::Animation
      animation = ya.move(0.5, self, x, y, bx, y)
      animation.parallel_add(ya::ScalarAnimation.new(0.5, self, :opacity=, 255, 0))
      animation.parallel_add(ya.se_play('fleee', 100, 60))
      animation.start
      animation_handler[:in_out] = animation
    end

    private

    # Reset the battler position
    def reset_position
      set_position(*sprite_position)
      self.z = basic_z_position
      set_origin(width / 2, height)
    end

    # Return the basic z position of the battler
    def basic_z_position
      z = @pokemon.bank == 0 ? 501 : 1
      z += @pokemon.position
      return z
    end

    # Get the base position of the Pokemon in 1v1
    # @return [Array(Integer, Integer)]
    def base_position_v1
      return 242, 138 if enemy?

      return 78, 184
    end

    # Get the base position of the Pokemon in 2v2+
    # @return [Array(Integer, Integer)]
    def base_position_v2
      return 202, 133 if enemy?

      return 58, 179
    end

    # Get the offset position of the Pokemon in 2v2+
    # @return [Array(Integer, Integer)]
    def offset_position_v2
      return 60, 10
    end

    # Load the battler of the Pokemon
    def load_battler
      if @last_pokemon&.id != @pokemon.id || @last_pokemon&.form != @pokemon.form || @last_pokemon&.code != @pokemon.code
        bitmap.dispose if @gif
        remove_instance_variable(:@gif) if instance_variable_defined?(:@gif)
        gif = pokemon.bank != 0 ? pokemon.gif_face : pokemon.gif_back
        if gif
          @gif = gif
          self.bitmap = Texture.new(gif.width, gif.height)
          gif.draw(bitmap)
        else
          self.bitmap = pokemon.bank != 0 ? pokemon.battler_face : pokemon.battler_back
        end
      end
      @last_pokemon = @pokemon.clone
    end

    # Creates the go_in animation (Exiting the ball)
    # @return [Yuki::Animation::TimedAnimation]
    def go_in_animation
      no_ball_trainer = $game_switches[Yuki::Sw::BT_NO_BALL_ANIMATION] && enemy?
      return follower_go_in_animation if pokemon.is_follower || no_ball_trainer

      return regular_go_in_animation
    end

    # Creates the go_out animation (Entering the ball if not KO, shading out if KO)
    # @return [Yuki::Animation::TimedAnimation]
    def go_out_animation
      return ko_go_out_animation if pokemon.dead?
      return follower_go_out_animation if pokemon.is_follower

      return regular_go_out_animation
    end

    # Creates the go_in animation of a "follower" pokemon
    # @return [Yuki::Animation::TimedAnimation]
    def follower_go_in_animation
      x, y = sprite_position
      bx = enemy? ? viewport.rect.width + width : -width
      $game_switches[Yuki::Sw::BT_NO_BALL_ANIMATION] = false if enemy?
      ya = Yuki::Animation
      animation = ya.send_command_to(self, :visible=, true)
      animation.play_before(ya.send_command_to(self, :zoom=, sprite_zoom))
      animation.play_before(ya.send_command_to(self, :opacity=, 255))
      animation.play_before(ya.move(0.1, self, bx, y, x, y))
      animation.play_before(ya.send_command_to(self, :cry))
      return animation
    end

    # Creates the regular go in animation (not follower)
    # @return [Yuki::Animation::TimedAnimation]
    def regular_go_in_animation
      ya = Yuki::Animation
      animation = ya.send_command_to(self, :visible=, true)
      animation.play_before(ya.send_command_to(self, :zoom=, 0))
      animation.play_before(ya.send_command_to(self, :opacity=, 255))
      animation.play_before(ya.send_command_to(self, :set_position, *sprite_position))
      poke_out = ya.scalar(0.1, self, :zoom=, 0, sprite_zoom)
      ball_animation = enemy? ? enemy_ball_animation(poke_out) : actor_ball_animation(poke_out)
      animation.play_before(ball_animation)
      animation.play_before(ya.send_command_to(self, :cry))

      return animation
    end

    # Creates the go_out animation of a "follower" pokemon
    # @return [Yuki::Animation::TimedAnimation]
    def follower_go_out_animation
      x, y = sprite_position
      bx = enemy? ? viewport.rect.width + width : -width
      return Yuki::Animation.move(0.1, self, x, y, bx, y)
    end

    # Creates the regular go out animation (not follower)
    # @return [Yuki::Animation::TimedAnimation]
    def regular_go_out_animation
      ya = Yuki::Animation
      animation = ya.send_command_to(self, :zoom=, sprite_zoom)
      animation.play_before(go_back_ball_animation(ya.scalar(0.1, self, :zoom=, sprite_zoom, 0)))

      return animation
    end

    # Create the go_out animation of a KO pokemon
    # @return [Yuki::Animation::TimedAnimation]
    def ko_go_out_animation
      ya = Yuki::Animation
      animation = ya.send_command_to(self, :cry, true)
      going_down = ya.opacity_change(0.1, self, opacity, 0)
      animation.play_before(going_down)
      going_down.parallel_add(ya.move(0.1, self, x, y, x, y + DELTA_DEATH_Y))

      return animation
    end

    # Create the ball animation of the actor Pokemon
    # @param pokemon_going_out_of_ball_animation [Yuki::Animation::TimedAnimation]
    # @return [Yuki::Animation::TimedAnimation]
    def actor_ball_animation(pokemon_going_out_of_ball_animation)
      sprite = UI::ThrowingBallSprite.new(viewport, @pokemon)
      sprite.set_position(-sprite.ball_offset_y, y - sprite.trainer_offset_y)
      ya = Yuki::Animation
      animation = ya.scalar_offset(0.5, sprite, :y, :y=, 0, -64, distortion: :SQUARE010_DISTORTION)
      animation.parallel_play(ya.move(0.5, sprite, -sprite.ball_offset_y, y - sprite.trainer_offset_y, x, y - sprite.ball_offset_y))
      animation.parallel_play(ya.scalar(0.5, sprite, :throw_progression=, 0, 1))
      animation.parallel_play(ya.se_play(*sending_ball_se))
      animation.play_before(ya.se_play(*opening_ball_se))
      animation.play_before(ya.scalar(0.1, sprite, :open_progression=, 0, 1))
      animation.play_before(ya.send_command_to(sprite, :dispose))
      animation.play_before(pokemon_going_out_of_ball_animation)

      return animation
    end

    # Create the ball animation of the enemy Pokemon
    # @param pokemon_going_out_of_ball_animation [Yuki::Animation::TimedAnimation]
    # @return [Yuki::Animation::TimedAnimation]
    def enemy_ball_animation(pokemon_going_out_of_ball_animation)
      sprite = UI::ThrowingBallSprite.new(viewport, @pokemon)
      sprite.set_position(*sprite_position)
      sprite.y -= sprite.ball_offset_y
      ya = Yuki::Animation
      animation = ya.wait(0.2)
      animation.play_before(ya.se_play(*opening_ball_se))
      animation.play_before(ya.scalar(0.1, sprite, :open_progression=, 0, 1))
      animation.play_before(ya.send_command_to(sprite, :dispose))
      animation.play_before(pokemon_going_out_of_ball_animation)

      return animation
    end

    # Create the ball animation of the Pokemon going back in ball
    # @param pokemon_going_in_the_ball_animation [Yuki::Animation::TimedAnimation]
    # @return [Yuki::Animation::TimedAnimation]
    def go_back_ball_animation(pokemon_going_in_the_ball_animation)
      sprite = UI::ThrowingBallSprite.new(viewport, @pokemon)
      sprite.set_position(*sprite_position)
      sprite.y -= sprite.ball_offset_y
      ya = Yuki::Animation
      animation = ya.wait(0.2)
      animation.play_before(ya.se_play(*back_ball_se))
      animation.play_before(ya.scalar(0.1, sprite, :open_progression=, 0, 1))
      animation.play_before(ya.send_command_to(sprite, :dispose))
      animation.play_before(pokemon_going_in_the_ball_animation)

      return animation
    end

    # SE played when the ball is sent
    def sending_ball_se
      return 'fall'
    end

    # SE played when the ball is opening
    def opening_ball_se
      return 'pokeopen'
    end

    # SE played when the Pokemon back to the ball
    def back_ball_se
      return 'pokeopen'
    end

    # Pokemon sprite zoom
    # @return [Integer]
    def sprite_zoom
      return 1
    end
  end
end
