module Battle
  class Visual
    module Transition
      # Trainer Transition of gen6
      class Gen6Trainer < Base
        # Unitary deltaX of the background
        DX = -Math.cos(-3 * Math::PI / 180)
        # Unitary deltaY of the background
        DY = Math.sin(-3 * Math::PI / 180)

        private

        # Function that creates all the sprites
        def create_all_sprites
          super
          create_background
          create_degrade
          create_halos
          create_battlers
          create_shader
          @viewport.sort_z
        end

        def create_background
          @background = Sprite.new(@viewport).set_origin(@viewport.rect.width, @viewport.rect.height)
          @background.set_position(@viewport.rect.width / 2, @viewport.rect.height / 2)
          @background.set_bitmap('battle_bg', :transition)
          @background.angle = -3
          @background.z = @screenshot_sprite.z - 1
          @to_dispose << @background
        end

        def create_degrade
          @degrade = Sprite.new(@viewport).set_origin(0, 90).set_position(0, 90).set_bitmap('battle_deg', :transition)
          @degrade.zoom_y = 0.10
          @degrade.opacity = 255 * @degrade.zoom_y
          @degrade.z = @background.z
          @to_dispose << @degrade
        end

        def create_halos
          @halo1 = Sprite.new(@viewport).set_bitmap('battle_halo1', :transition)
          @halo1.z = @background.z
          @to_dispose << @halo1
          @halo2 = Sprite.new(@viewport).set_origin(-640, 0).set_bitmap('battle_halo2', :transition)
          @halo2.z = @background.z
          @to_dispose << @halo2
          @halo3 = Sprite.new(@viewport).set_origin(-640, 0).set_position(640, 0).set_bitmap('battle_halo2', :transition)
          @halo3.z = @background.z
          @to_dispose << @halo3
        end

        def create_battlers
          filename = @scene.battle_info.battlers[1][0]
          @battler = Sprite.new(@viewport).set_bitmap(filename + '_sma', :battler)
          @battler.set_position(-@battler.width / 4, @viewport.rect.height)
          @battler.set_origin(@battler.width / 2, @battler.height)
          @battler.z = @background.z
          @battler2 = Sprite.new(@viewport).set_bitmap(filename + '_big', :battler)
          @battler2.set_position(@viewport.rect.width / 2, @viewport.rect.height)
          @battler2.set_origin(@battler2.width / 2, @battler2.height)
          @battler2.z = @background.z
          @battler2.opacity = 0
          @actor_sprites = actor_sprites
        end

        def create_shader
          @shader = Shader.create(:battle_backout)
          6.times do |i|
            @shader.set_texture_uniform("bk#{i}", RPG::Cache.transition("black_out0#{i}"))
          end
          @screenshot_sprite.shader = @shader
          @shader_time_update = proc { |t| @shader.set_float_uniform('time', t) }
        end

        def create_pre_transition_animation
          root = Yuki::Animation::ScalarAnimation.new(1.2, @shader_time_update, :call, 0, 1)
          root.play_before(Yuki::Animation.send_command_to(Graphics, :freeze))
          root.play_before(Yuki::Animation.send_command_to(@screenshot_sprite, :dispose))
          return root
        end

        def create_background_animation
          background_setter = proc do |i|
            t = (1 - Math.cos(2 * Math::PI * i)) / 10 + i
            d = (t * 1200) % 120
            @background.set_position(d * DX + @viewport.rect.width / 2, d * DY + @viewport.rect.height / 2)
          end
          root = Yuki::Animation::TimedLoopAnimation.new(10)
          root.play_before(Yuki::Animation::ScalarAnimation.new(10, background_setter, :call, 0, 1))
          root.parallel_play(halo = Yuki::Animation::TimedLoopAnimation.new(0.5))
          halo.play_before(h1 = Yuki::Animation::ScalarAnimation.new(0.5, @halo2, :ox=, 0, 640))
          h1.parallel_play(Yuki::Animation::ScalarAnimation.new(0.5, @halo3, :ox=, 0, 640))
          return root
        end

        def create_paralax_animation
          root = Yuki::Animation.wait(0.1)
          root.play_before(Yuki::Animation::ScalarAnimation.new(0.4, @degrade, :zoom_y=, 0.10, 1.25))
          root.parallel_play(Yuki::Animation.opacity_change(0.2, @degrade, 0, 255))
          root.play_before(Yuki::Animation::ScalarAnimation.new(0.1, @degrade, :zoom_y=, 1.25, 1))
          return root
        end

        def create_sprite_move_animation
          root = Yuki::Animation.move(0.6, @battler, @battler.x, @battler.y, @viewport.rect.width / 2, @battler.y)
          root.play_before(Yuki::Animation.wait(0.3))
          root.play_before(fade = Yuki::Animation.opacity_change(0.4, @battler, 255, 0))
          fade.parallel_play(Yuki::Animation.opacity_change(0.4, @battler2, 0, 255))
          return root
        end

        def create_enemy_send_animation
          enemy_sprites.each { |sp| sp.visible = false }
          root = Yuki::Animation.move(0.4, @battler2, @battler2.x, @battler2.y, @battler2.x - 40, @battler2.y)
          root.play_before(go = Yuki::Animation.move(0.4, @battler2, @battler2.x - 40, @battler2.y, @viewport.rect.width * 1.5, @battler2.y))
          go.parallel_play(Yuki::Animation.opacity_change(0.4, @battler2, 255, 0))
          root.play_before(Yuki::Animation.send_command_to(Graphics, :freeze))
          root.play_before(Yuki::Animation.send_command_to(self, :hide_all_sprites))
          root.play_before(Yuki::Animation.send_command_to(Graphics, :transition))
          # TODO add ball
          enemy_pokemon_sprites.each do |sp|
            root.play_before(Yuki::Animation.send_command_to(sp, :go_in))
          end
          return root
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

        def hide_all_sprites
          @to_dispose.each do |sprite|
            sprite.visible = false if sprite.is_a?(Sprite)
          end
        end
      end
    end
    TRAINER_TRANSITIONS[0] = Transition::Gen6Trainer
  end
end
