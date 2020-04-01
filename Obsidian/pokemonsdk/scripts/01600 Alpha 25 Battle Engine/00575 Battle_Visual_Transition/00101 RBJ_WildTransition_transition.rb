module Battle
  class Visual
    class RBJ_WildTransition
      # Number of frame to move the sprites
      SPRITE_MOVE_DURATION = 60
      # Number of pixel the sprites moves each frames
      SPRITE_MOVE_PIXEL = 6
      # Set the Transition in Transition mode
      def transition
        Graphics.freeze
        @battle_scene.message_window.visible = true
        @battle_scene.message_window.blocking = true
        @battle_scene.message_window.wait_input = true
        @update_method = :update_transition
        @counter = 0
        @viewport.color.set(0, 0, 0, 0)
        @viewport.sort_z
        @shader = Shader.new(Shader::GeneralColorSprite)
        @shader.set_float_uniform('color', [0, 0, 0, 1])
        load_enemy_sprites
        load_actors_sprites
        Graphics.transition(15)
        @done = false
      end

      private

      # Update the transition animation
      def update_transition
        return if $game_temp.message_window_showing
        if @counter < SPRITE_MOVE_DURATION
          update_transition_move_sprite
        elsif @counter == SPRITE_MOVE_DURATION
          update_transition_move_sprite_end
        elsif @counter == SPRITE_MOVE_DURATION + 1
          update_transition_enemy_sending_pokemon
        elsif @counter == SPRITE_MOVE_DURATION + 2
          update_transition_actor_sending_pokemon
        end
        @counter += 1
        unless @counter < SPRITE_MOVE_DURATION + 4
          @battle_scene.visual.unlock
          @battle_scene.visual.show_info_bars
          @done = true
        end
      end

      # Move the sprites during the update transition
      def update_transition_move_sprite
        @actor_sprites.each { |sprite| sprite.x -= SPRITE_MOVE_PIXEL }
        @enemy_sprites.each { |sprite| sprite.x += SPRITE_MOVE_PIXEL }
        1.upto(@grounds.size - 1) { |index| @grounds[index].x += SPRITE_MOVE_PIXEL }
        @grounds.first.x -= SPRITE_MOVE_PIXEL
      end

      # Execute the last frame of the move sprite
      def update_transition_move_sprite_end
        @enemy_sprites.each do |sprite|
          sprite.shader = nil
          sprite.cry if sprite.is_a?(BattleUI::PokemonSprite)
        end
        @battle_scene.display_message(first_message)
        @battle_scene.message_window.blocking = false
      end

      # Execute the part where the enemy (trainer) is sending its pokemon out
      def update_transition_enemy_sending_pokemon
        message = second_message
        if message
          @counter2 = 0
          @update_method = :update_enemy_sending_pokemon
          @battle_scene.display_message(message)
        end
      end

      # Execute the part where the actor (trainer) is sending its pokemon out
      def update_transition_actor_sending_pokemon
        @counter2 = 0
        @update_method = :update_player_sending_pokemon
      end

      # Update the trainer sending Pokemon
      def update_player_sending_pokemon
        if @counter2 == 10
          @actor_sprites.each(&:show_next_frame)
          spawn_player_balls
          @counter2 += 1
          @battle_scene.display_message(third_message)
        elsif @counter2 == 60
          start_actor_mon_going_out_animation
        elsif @counter2 > 70
          @update_method = :update_transition
        end
        @actor_sprites.each { |sprite| sprite.x -= SPRITE_MOVE_PIXEL / 2 }
        @counter2 += 1
      end

      # Load the enemy sprites
      def load_enemy_sprites
        @enemy_sprites = enemy_sprites
        @enemy_sprites.each do |sprite|
          sprite.shader = @shader
          sprite.x -= SPRITE_MOVE_DURATION * SPRITE_MOVE_PIXEL
        end
        1.upto(@grounds.size - 1) { |index| @grounds[index].x -= SPRITE_MOVE_DURATION * SPRITE_MOVE_PIXEL }
      end

      # Get the enemy sprites
      # @return [Array<ShaderedSprite>]
      def enemy_sprites
        sprites = []
        $game_temp.vs_type.times do |i|
          sprite = @battle_scene.visual.battler_sprite(1, i)
          sprites << sprite if sprite
        end
        return sprites
      end

      # Load the actor sprites
      def load_actors_sprites
        @actor_sprites = actor_sprites
        @actor_sprites.each do |sprite|
          sprite.x += SPRITE_MOVE_DURATION * SPRITE_MOVE_PIXEL
        end
        @grounds.first.x += SPRITE_MOVE_DURATION * SPRITE_MOVE_PIXEL
      end

      # Get the actor sprites (and hide the mons)
      # @return [Array<ShaderedSprite>]
      def actor_sprites
        sprites = []
        $game_temp.vs_type.times do |i|
          sprite = @battle_scene.visual.battler_sprite(0, i)
          sprite&.zoom = 0
          sprite = @battle_scene.visual.battler_sprite(0, -i - 1)
          sprites << sprite if sprite
        end
        return sprites
      end

      # Spawn the player balls (to animate them)
      def spawn_player_balls
=begin
        @balls = Array.new($game_temp.vs_type) do |index|
          if (pokemon = @battle_scene.logic.battler(0, index))
            sprite = Sprite.new(@viewport)
            sprite.bitmap = pokemon.ball_image
            sprite.src_rect.set(0, 3 * 26, nil, 26)
            sprite.set_position()
            next(sprite)
          end
          next(nil)
        end
        @balls.compact!
        TODO : BallSprite class just to launch the Pokemon, same for enemies
=end
      end

      # Function that start the Actor pokemon going out of ball animation
      def start_actor_mon_going_out_animation
        $game_temp.vs_type.times do |i|
          @battle_scene.visual.battler_sprite(0, i)&.start_animation_going_out
        end
      end

      # Return the first message shown
      # @return [String]
      def first_message
        return Message.wild_battle_appearance
      end

      # Return the second message shown
      # @return [String, nil]
      def second_message
        return nil
      end

      # Return the third message shown
      # @return [String]
      def third_message
        return Message.player_sending_pokemon_start
      end
    end
  end
end
