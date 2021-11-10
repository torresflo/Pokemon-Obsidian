module Battle
  class Visual
    module Transition
      # Wild transition of Red/Blue/Yellow games
      class RBYWild < Base
        # Constant giving the X displacement done by the sprites
        DISPLACEMENT_X = 360

        private

        # Return the pre_transtion cells
        # @return [Array]
        def pre_transition_cells
          return 10, 3
        end

        # Return the pre_transtion sprite name
        # @return [String]
        def pre_transition_sprite_name
          'rbj/pre_wild'
        end

        # Function that creates all the sprites
        def create_all_sprites
          super
          create_top_sprite
          create_enemy_sprites
          create_actors_sprites
        end

        # Function that creates the top sprite
        def create_top_sprite
          @top_sprite = SpriteSheet.new(@viewport, *pre_transition_cells)
          @top_sprite.z = @screenshot_sprite.z * 2
          @top_sprite.set_bitmap(pre_transition_sprite_name, :transition)
          @top_sprite.zoom = @viewport.rect.width / @top_sprite.width.to_f
          @top_sprite.y = (@viewport.rect.height - @top_sprite.height * @top_sprite.zoom_y) / 2
          @top_sprite.visible = false
        end

        # Function that creates the enemy sprites
        def create_enemy_sprites
          @shader = Shader.create(:color_shader)
          @shader.set_float_uniform('color', [0, 0, 0, 1])
          @enemy_sprites = enemy_pokemon_sprites
          @enemy_sprites.each do |sprite|
            sprite.shader = @shader
            sprite.x -= DISPLACEMENT_X
          end
        end

        # Function that creates the actor sprites
        def create_actors_sprites
          @actor_sprites = actor_sprites
          @actor_sprites.each do |sprite|
            sprite.x += DISPLACEMENT_X
          end
        end

        # Function that creates the Yuki::Animation related to the pre transition
        # @return [Yuki::Animation::TimedAnimation]
        def create_pre_transition_animation
          flasher = proc do |x|
            sin = Math.sin(x)
            col = sin.ceil.clamp(0, 1) * 255
            alpha = (sin.abs2.round(2) * 180).to_i
            @viewport.color.set(col, col, col, alpha)
          end
          ya = Yuki::Animation
          animation = ya::ScalarAnimation.new(1.5, flasher, :call, 0, 6 * Math::PI)
          animation.play_before(ya.send_command_to(@viewport.color, :set, 0, 0, 0, 0))
          animation.play_before(ya.send_command_to(@top_sprite, :visible=, true))
          animation.play_before(create_fadein_animation)
          animation.play_before(ya.send_command_to(@viewport.color, :set, 0, 0, 0, 255))
          animation.play_before(ya.send_command_to(@top_sprite, :dispose))
          animation.play_before(ya.send_command_to(@screenshot_sprite, :dispose))
          animation.play_before(ya.wait(0.25))
          return animation
        end

        # Function that creates the fade in animation
        def create_fadein_animation
          # We need to display all the cells in order so we will build an array from that
          cells = (@top_sprite.nb_x * @top_sprite.nb_y).times.map { |i| [i % @top_sprite.nb_x, i / @top_sprite.nb_x] }
          # We create the cell animation
          return Yuki::Animation::SpriteSheetAnimation.new(0.5, @top_sprite, cells)
        end

        # Function that create the fade out animation
        # @return [Yuki::Animation::TimedAnimation]
        def create_fade_out_animation
          animation = Yuki::Animation.send_command_to(@viewport.color, :set, 0, 0, 0, 0)
          animation.play_before(Yuki::Animation.send_command_to(Graphics, :transition, 15))
          return animation
        end

        # Function that create the sprite movement animation
        # @return [Yuki::Animation::TimedAnimation]
        def create_sprite_move_animation
          ya = Yuki::Animation
          animations = @enemy_sprites.map do |sp|
            ya.move(0.8, sp, sp.x, sp.y, sp.x + DISPLACEMENT_X, sp.y)
          end
          # @type [Yuki::Animation::TimedAnimation]
          animation = animations.pop
          animations.each { |a| animation.parallel_add(a) }
          @actor_sprites.each do |sp|
            animation.parallel_add(ya.move(0.8, sp, sp.x, sp.y, sp.x - DISPLACEMENT_X, sp.y))
          end
          @enemy_sprites.each { |sp| animation.play_before(ya.send_command_to(sp, :shader=, nil)) }
          cries = @enemy_sprites.select { |sp| sp.respond_to?(:cry) }
          cries.each { |sp| animation.play_before(ya.send_command_to(sp, :cry)) }
          return animation
        end

        # Function that create the animation of the player sending its Pokemon
        # @return [Yuki::Animation::TimedAnimation]
        def create_player_send_animation
          ya = Yuki::Animation
          animations = @actor_sprites.map do |sp|
            next ya.move(1, sp, sp.x, sp.y, -sp.width, sp.y).parallel_play(
              ya.wait(0.2).play_before(ya.send_command_to(sp, :show_next_frame)).root
            )
          end
          animation = animations.pop
          animations.each { |anim| animation.parallel_add(anim) }
          actor_pokemon_sprites.each do |sp|
            animation.play_before(ya.send_command_to(sp, :go_in))
          end
          animation.play_before(ya.wait(0.2))
          return animation
        end
      end
    end

    WILD_TRANSITIONS[2] = Transition::RBYWild
    WILD_TRANSITIONS[0] = Transition::RBYWild
  end
end
