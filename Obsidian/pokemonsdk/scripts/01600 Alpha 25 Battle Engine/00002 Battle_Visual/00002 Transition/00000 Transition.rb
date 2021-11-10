module Battle
  class Visual
    # Module holding all the Battle transition
    module Transition
      # Base class of all transitions
      class Base
        # Create a new transition
        # @param scene [Battle::Scene]
        # @param screenshot [Texture]
        def initialize(scene, screenshot)
          @scene = scene
          @visual = scene.visual
          @viewport = @visual.viewport
          @screenshot = screenshot
          # @type [Array<Yuki::Animation>]
          @animations = []
          # @type [Array<Texture, Sprite>]
          @to_dispose = [screenshot]
        end

        # Update the transition
        def update
          @animations.each(&:update)
        end

        # Tell if the transition is done
        # @return [Boolean]
        def done?
          return @animations.all?(&:done?)
        end

        # Dispose the transition (safely clean all things that needs to be disposed)
        def dispose
          @to_dispose.each do |disposable|
            disposable.dispose unless disposable.disposed?
          end
        end

        # Start the pre transition (fade in)
        #
        # - Initialize **all** the sprites
        # - Create all the pre-transition animations
        # - Force Graphics transition if needed.
        def pre_transition
          create_all_sprites
          @animations.clear
          transition = create_pre_transition_animation
          transition.play_before(Yuki::Animation.send_command_to(@visual, :unlock))
          @animations << transition
          Graphics.transition(1) # Force graphics to be unfrozen
          @animations.each(&:start)
        end

        # Start the transition (fade out)
        #
        # - Create all the transition animation
        # - Add all the message to the animation
        # - Add the send enemy Pokemon animation
        # - Add the send actor Pokemon animation
        def transition
          @animations.clear
          @scene.message_window.visible = true
          @scene.message_window.blocking = true
          @scene.message_window.stay_visible = true
          @scene.message_window.wait_input = true
          ya = Yuki::Animation
          main = create_fade_out_animation
          main.play_before(create_sprite_move_animation)
          @animations << main
          @animations << create_background_animation
          @animations << create_paralax_animation
          # Appearing section
          main.play_before(ya.message_locked_animation)
              .play_before(ya.send_command_to(self, :show_appearing_message))
              .play_before(ya.send_command_to(@scene.visual, :show_team_info))
              .play_before(ya.send_command_to(self, :start_enemy_send_animation))
          @animations.each(&:start)
        end

        # Function that starts the Enemy send animation
        def start_enemy_send_animation
          log_debug('start_enemy_send_animation')
          ya = Yuki::Animation
          animation = create_enemy_send_animation
          # Add message display in parallel
          animation.parallel_add(ya.send_command_to(self, :show_enemy_send_message))
          animation.play_before(ya.message_locked_animation)
          # Once everything is done, start the actor sending Pokemon animation
          animation.play_before(ya.send_command_to(self, :start_actor_send_animation))
          animation.start
          @animations << animation
        end

        # Function that starts the Actor send animation
        def start_actor_send_animation
          log_debug('start_actor_send_animation')
          ya = Yuki::Animation
          animation = create_player_send_animation
          # Add message display in parallel
          animation.parallel_add(
            ya.message_locked_animation.play_before(ya.send_command_to(self, :show_player_send_message))
          )
          # Once everything is done, unlock everything
          animation.play_before(ya.send_command_to(@visual, :unlock))
                   .play_before(ya.send_command_to(self, :dispose))
          animation.start
          @animations << animation
        end

        private

        # Function that creates all the sprites
        #
        # Please, call super of this function if you want to get the screenshot sprite!
        def create_all_sprites
          @screenshot_sprite = ShaderedSprite.new(@viewport)
          @screenshot_sprite.bitmap = @screenshot
          @screenshot_sprite.z = 100_000
        end

        # Function that creates the Yuki::Animation related to the pre transition
        # @return [Yuki::Animation::TimedAnimation]
        def create_pre_transition_animation
          animation = Yuki::Animation.send_command_to(Graphics, :freeze)
          animation.play_before(Yuki::Animation.send_command_to(@screenshot_sprite, :dispose))
          return animation
        end

        # Function that create the fade out animation
        # @return [Yuki::Animation::TimedAnimation]
        def create_fade_out_animation
          return Yuki::Animation.send_command_to(Graphics, :transition)
        end

        # Function that create the sprite movement animation
        # @return [Yuki::Animation::TimedAnimation]
        def create_sprite_move_animation
          return Yuki::Animation.wait(0)
        end

        # Function that creates the background movement animation
        # @return [Yuki::Animation::TimedAnimation]
        def create_background_animation
          return Yuki::Animation.wait(0)
        end

        # Function that create the paralax animation
        # @return [Yuki::Animation::TimedLoopAnimation]
        def create_paralax_animation
          return Yuki::Animation::TimedLoopAnimation.new(100)
        end

        # Function that create the animation of the enemy sending its Pokemon
        # @return [Yuki::Animation::TimedAnimation]
        def create_enemy_send_animation
          return Yuki::Animation.wait(0)
        end

        # Function that create the animation of the player sending its Pokemon
        # @return [Yuki::Animation::TimedAnimation]
        def create_player_send_animation
          return Yuki::Animation.wait(0)
        end

        # Function that shows the message about Wild appearing / Trainer wanting to fight
        def show_appearing_message
          @scene.display_message(appearing_message)
          @scene.message_window.blocking = false
        end

        # Return the "appearing/issuing" message
        # @return [String]
        def appearing_message
          return @scene.battle_info.trainer_battle? ? Message.trainer_issuing_a_challenge : Message.wild_battle_appearance
        end

        # Function that shows the message about enemy sending its Pokemon
        def show_enemy_send_message
          return unless @scene.battle_info.trainer_battle?

          @scene.display_message(enemy_send_message)
        end

        # Return the "Enemy sends out" message
        # @return [String]
        def enemy_send_message
          return Message.trainer_sending_pokemon_start
        end

        # Function that shows the message about player sending its Pokemon
        def show_player_send_message
          @scene.message_window.stay_visible = false
          @scene.display_message(player_send_message)
        end

        # Return the third message shown
        # @return [String]
        def player_send_message
          return Message.player_sending_pokemon_start
        end

        # Get the enemy Pokemon sprites
        # @return [Array<ShaderedSprite>]
        def enemy_pokemon_sprites
          sprites = $game_temp.vs_type.times.map do |i|
            @scene.visual.battler_sprite(1, i)
          end.compact.select(&:pokemon).select { |sprite| sprite.pokemon.alive? }
          return sprites
        end

        # Get the actor sprites (and hide the mons)
        # @return [Array<ShaderedSprite>]
        def actor_sprites
          sprites = $game_temp.vs_type.times.map do |i|
            @scene.visual.battler_sprite(0, i)&.zoom = 0
            next @scene.visual.battler_sprite(0, -i - 1)
          end.compact
          return sprites
        end

        # Get the actor Pokemon sprites
        # @return [Array<ShaderedSprite>]
        def actor_pokemon_sprites
          sprites = $game_temp.vs_type.times.map do |i|
            @scene.visual.battler_sprite(0, i)
          end.compact.select(&:pokemon).select { |sprite| sprite.pokemon.alive? }
          return sprites
        end

        # Function that gets the enemy sprites (and hide the mons)
        # @return [Array<ShaderedSprite>]
        def enemy_sprites
          sprites = $game_temp.vs_type.times.map do |i|
            @scene.visual.battler_sprite(1, i)&.zoom = 0
            next @scene.visual.battler_sprite(1, -i - 1)
          end.compact
          return sprites
        end
      end
    end

    WILD_TRANSITIONS.default = Transition::Base
    TRAINER_TRANSITIONS.default = Transition::Base
  end
end
