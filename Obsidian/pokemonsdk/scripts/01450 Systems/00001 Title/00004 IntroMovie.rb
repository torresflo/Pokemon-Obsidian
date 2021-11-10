class Scene_Title
  private

  # Show the intro movie map
  # @param map_id [Integer] ID of the map
  def start_intro_movie(map_id)
    Graphics.update until all_data_loaded?
    Graphics.freeze
    @viewport.visible = false
    $tester = true # No new GameMap hack
    $pokemon_party = PFM::Pokemon_Party.new(false, $pokemon_party&.options&.language || PSDK_CONFIG.default_language_code)
    $tester = nil
    Yuki::MapLinker.reset
    $pokemon_party.expand_global_var
    $game_party.setup_starting_members
    $game_map.setup(map_id)
    $game_player.moveto(Yuki::MapLinker.get_OffsetX, Yuki::MapLinker.get_OffsetY)
    $game_player.refresh
    $game_map.autoplay
    scene = $scene
    $scene = Scene_Map.new
    $scene.main
    $scene = scene
    GamePlay::Save.load
    @viewport.visible = true
    Graphics.transition
  end
end
