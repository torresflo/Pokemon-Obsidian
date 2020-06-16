# The map gameplay scene
class Scene_Map < GamePlay::Base
  include Hooks
  # Access to the spriteset of the map
  # @return [Spriteset_Map]
  attr_reader :spriteset
  # Create a new Scene_Map
  def initialize
    super
    @update_to_call = []
    Scheduler.start(:on_init, self.class)
  end

  # Update the scene process
  def update
    auto_transfert_update
    update_graphics
    return false if switched_to_main_rmxp_scene
    return false unless super # Update message window & break if messages are shown

    update_scene_calling
  ensure
    @running = false if $scene != self
  end

  # Section where we update the graphics of the scene (for now only spriteset)
  def update_graphics
    @spriteset.update
  end

  # Change the viewport visibility of the scene (we overwrite it because we don't want viewport to be hidden when calling a scene)
  # @param value [Boolean]
  def visible=(value)
    @message_window.viewport.visible = value if @message_window
  end

  # Update everything related to the graphics of the map (used in Interfaces that require that)
  def sprite_set_update
    $game_screen.update
    $game_map.refresh if $game_map.need_refresh
    @spriteset.update
  end

  # Change the spriteset visibility
  # @param v [Boolean] the new visibility of the spriteset
  def sprite_set_visible=(v)
    @spriteset.visible = v
  end

  # Display the repel check sequence
  def display_repel_check
    display_message(parse_text(39, 0))
  end

  # Display the end of poisoning sequence
  # @param pokemon [PFM::Pokemon] previously poisoned pokemon
  def display_poison_end(pokemon)
    PFM::Text.set_pknick(pokemon, 0)
    display_message(parse_text(22, 110))
  end

  # Display the poisoning animation sequence
  def display_poison_animation
    Audio.se_play('Audio/SE/psn')
    $game_screen.start_flash(GameData::Colors::PSN, 20)
    $game_screen.start_shake(1, 20, 2)
  end

  # Display the Egg hatch sequence
  # @param pokemon [PFM::Pokemon] haching pokemon
  def display_egg_hatch(pokemon)
    call_scene(GamePlay::Hatch, pokemon)
    $quests.hatch_egg
  end

  # Prepare the call of a display_ method
  # @param args [Array] the send method parameter
  def delay_display_call(*args)
    @update_to_call << args
  end

  # Force the message window to close
  # @param smooth [Boolean] if the message window is closed smoothly or not
  def window_message_close(smooth)
    if smooth
      while $game_temp.message_window_showing
        Graphics.update
        @message_window.update
      end
    else
      $game_temp.message_window_showing = false
      @message_window.visible = false
      @message_window.opacity = 255
    end
  end

  # Take a snapshot of the scene
  # @note You have to dispose the bitmap you got from this function
  # @return [Bitmap]
  def snap_to_bitmap
    back_bitmap = @viewport.snap_to_bitmap
    if (vp = NuriYuri::DynamicLight.viewport)&.visible
      shader = vp.shader
      vp.shader = nil
      top_bitmap = vp.snap_to_bitmap
      vp.shader = shader
      vp = Viewport.create(:main)
      back = Sprite.new(vp).set_bitmap(back_bitmap)
      top = ShaderedSprite.new(vp).set_bitmap(top_bitmap)
      top.shader = shader
      exec_hooks(Scene_Map, :snap_to_bitmap, binding)
      result = vp.snap_to_bitmap
      exec_hooks(Scene_Map, :snaped_to_bitmap, binding)
      vp.dispose
      back_bitmap.dispose
      top_bitmap.dispose
      return result
    end
    return back_bitmap
  end

  private

  # The main process at the begin of scene
  def main_begin
    create_spriteset
    # When comming back from battle we ensure that we don't have a weird transition by warping immediately
    if $game_temp.player_transferring
      transfer_player
    else
      $wild_battle.reset
      $wild_battle.load_groups
    end
    fade_in(@mbf_type || DEFAULT_TRANSITION, @mbf_param || DEFAULT_TRANSITION_PARAMETER)
    $quests.check_up_signal
  end

  # Create the spriteset
  def create_spriteset
    add_disposable @spriteset = Spriteset_Map.new($env.update_zone)
    # We assign the current viewport to map_viewport
    @viewport = @spriteset.map_viewport
  end

  # Section of the update where we ensure that the game player is transfering correctly
  def auto_transfert_update
    loop do
      # Updating game_map, interpreter & player should be done in this order (to prevent player from moving before events do something)
      $game_map.update
      $game_system.map_interpreter.update
      $game_player.update
      # Update the screen information
      $game_system.update
      $game_screen.update
      # If the player is not warping (event asked for it / MapLinker asked for it we stop the loop)
      break unless $game_temp.player_transferring
      # Otherwise we transfert the player
      transfer_player
      # If there's a transition we don't try to update the map & interpreter again we let the transition do its job
      break if $game_temp.transition_processing
    end
  end

  # Section of the update where we test if the game switched to a main RMXP scene
  # @note we also process transition here
  # @return [Boolean] if a switch was done
  def switched_to_main_rmxp_scene
    if $game_temp.gameover
      $scene = Scene_Gameover.new
      return true
    elsif $game_temp.to_title
      $scene = Scene_Title.new
      return true
    elsif $game_temp.transition_processing
      $game_temp.transition_processing = false
      if $game_temp.transition_name.empty?
        Graphics.transition(20)
      else
        Graphics.transition(60, RPG::Cache.transition($game_temp.transition_name))
      end
    end
    return false
  end
end
