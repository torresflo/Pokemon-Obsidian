module Yuki
  # Module that manage the Animation Editor
  module AnimationEditor
    
    module_function
    # Main function called by the regular Game Loop
    def main
      init
      Graphics.transition
      loop do Graphics.update end
    end
    # Init function to init the editor
    def init
      init_env
      init_battle_scene
    end
    # Initialize the PSDK environment
    def init_env
      $tester = self
      $pokemon_party = PFM::Pokemon_Party.new
      $pokemon_party.expand_global_var
      $game_temp.vs_type = 1
      @global_animation = {origin: [], target: []}
      @origin_frames = [] #Array holding all the animation frame (actions until :synchronise) of the origin
      @target_frames = []
    end
    # Initialize the Battle scene to make animation more visual
    def init_battle_scene
      @main_background = Sprite.new.set_bitmap("animation_editor", :interface)
      @main_background.z = -1024
      @battle_viewport = Viewport.create(:main, 1000)
      @battle_bars = []
      pokemon = ::PFM::Pokemon.new(rand($game_data_pokemon.size - 1) + 1, 1)
      pokemon.position = -1
      @battle_enemy_sprite = ::GamePlay::BattleSprite.new(@battle_viewport, pokemon)
      @battle_bars << ::GamePlay::BattleBar.new(@battle_viewport, pokemon)
      pokemon = ::PFM::Pokemon.new(rand($game_data_pokemon.size - 1) + 1, 1)
      pokemon.position = 0
      @battle_actor_sprite = ::GamePlay::BattleSprite.new(@battle_viewport, pokemon)
      @battle_bars << ::GamePlay::BattleBar.new(@battle_viewport, pokemon)
      @battle_background = Sprite.new(@battle_viewport).set_bitmap("back_grass", :battleback)
      @message_window = @message_window = Scene_Battle::Window_Message.new(@battle_viewport)
      @main_animator = Basic_Animator.new(@global_animation, @battle_actor_sprite, @battle_enemy_sprite)
      @battle_viewport.sort_z
    end
    # get the bars
    def get_battle_bars
      @battle_bars
    end
  end
  
  class Basic_Animator
    # Return the stack holding all the sprites related to a target
    # @return [Array<Sprite>]
    def get_target_sprites
      @sprites[@origin_sprite.__id__ + 1]
    end
    # Return the stack holding all the sprites related to the origin
    # @return [Array<Sprite>]
    def get_origin_sprites
      @sprites[@origin_sprite.__id__ + 1]
    end
    # Hide Bars
    def hide_bars
      AnimationEditor.get_battle_bars.each { |sprite| sprite.visible = false }
    end
    # Show Bars
    def show_bars
      AnimationEditor.get_battle_bars.each { |sprite| sprite.visible = true }
    end
    # Dispose every generated Sprite in this animation
    def dispose
      @sprites.each do |id,stack|
        stack.each do |sprite|
          sprite.dispose
        end
        stack.clear
      end
    end
  end
end