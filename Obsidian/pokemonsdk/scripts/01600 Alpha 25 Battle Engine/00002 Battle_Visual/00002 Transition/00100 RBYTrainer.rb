module Battle
  class Visual
    module Transition
      # Trainer transition of Red/Blue/Yellow games
      class RBYTrainer < Base
        # Constant giving the X displacement done by the sprites
        DISPLACEMENT_X = 360

        private

        # Return the pre_transtion sprite name
        # @return [String]
        def pre_transition_sprite_name
          'rbj/trainer'
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
          @top_sprite = ShaderedSprite.new(@viewport)
          @top_sprite.z = @screenshot_sprite.z * 2
          @top_sprite.set_bitmap(pre_transition_sprite_name, :transition)
          @top_sprite.zoom = @viewport.rect.width / @top_sprite.width.to_f
          @top_sprite.y = (@viewport.rect.height - @top_sprite.height * @top_sprite.zoom_y) / 2
          @top_sprite.shader = Shader.create(:rby_trainer)
        end

        # Function that creates the enemy sprites
        def create_enemy_sprites
          @enemy_sprites = enemy_sprites
          @enemy_sprites.each do |sprite|
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
          transitioner = proc { |t| @top_sprite.shader.set_float_uniform('t', t) }
          ya = Yuki::Animation
          animation = ya::ScalarAnimation.new(2.75, transitioner, :call, 0, 1)
          animation.play_before(ya.send_command_to(@viewport.color, :set, 0, 0, 0, 255))
          animation.play_before(ya.send_command_to(@top_sprite, :dispose))
          animation.play_before(ya.send_command_to(@screenshot_sprite, :dispose))
          animation.play_before(ya.wait(0.25))
          return animation
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

        # Function that create the animation of the enemy sending its Pokemon
        # @return [Yuki::Animation::TimedAnimation]
        def create_enemy_send_animation
          ya = Yuki::Animation
          animations = @enemy_sprites.map do |sp|
            next ya.move(0.8, sp, sp.x, sp.y, @viewport.rect.width + sp.width, sp.y).parallel_play(
              ya.wait(0.2).play_before(ya.send_command_to(sp, :show_next_frame)).root
            )
          end
          animation = animations.pop
          animations.each { |anim| animation.parallel_add(anim) }
          enemy_pokemon_sprites.each do |sp|
            animation.play_before(ya.send_command_to(sp, :go_in))
          end
          return animation
        end
      end
    end

    TRAINER_TRANSITIONS[2] = Transition::RBYTrainer
  end
end

Graphics.on_start do
  Shader.register(:rby_trainer, 'graphics/shaders/rbytrainer.frag')
end
