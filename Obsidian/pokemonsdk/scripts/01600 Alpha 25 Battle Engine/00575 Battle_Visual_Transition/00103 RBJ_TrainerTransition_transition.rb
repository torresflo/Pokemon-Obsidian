module Battle
  class Visual
    class RBJ_TrainerTransition

      private

      # Get the enemy sprites
      # @return [Array<ShaderedSprite>]
      def enemy_sprites
        sprites = []
        $game_temp.vs_type.times do |i|
          sprite = @battle_scene.visual.battler_sprite(1, i)
          sprite&.zoom = 0
          sprite = @battle_scene.visual.battler_sprite(1, -i - 1)
          sprites << sprite if sprite
        end
        return sprites
      end

      # Return the first message shown
      # @return [String]
      def first_message
        return Message.trainer_issuing_a_challenge
      end

      # Return the second message shown
      # @return [String]
      def second_message
        return Message.trainer_sending_pokemon_start
      end

      # Update the enemy sending their pokemon
      def update_enemy_sending_pokemon
        if @counter2 == 10
          spawn_enemy_balls
        elsif @counter2 == 60
          start_enemy_mon_going_out_animation
        elsif @counter2 > 90
          @update_method = :update_transition
        end
        @enemy_sprites.each { |sprite| sprite.x += SPRITE_MOVE_PIXEL / 2 }
        @counter2 += 1
      end

      # Spawn the ball of the enemy
      def spawn_enemy_balls
        # TODO
      end

      # Function that start the enemy pokemon going out of ball animation
      def start_enemy_mon_going_out_animation
        $game_temp.vs_type.times do |i|
          @battle_scene.visual.battler_sprite(1, i)&.start_animation_going_out
        end
      end
    end
  end
end
