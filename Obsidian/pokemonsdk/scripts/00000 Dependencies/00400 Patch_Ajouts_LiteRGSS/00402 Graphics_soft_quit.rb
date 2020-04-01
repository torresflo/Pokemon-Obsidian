=begin
module Graphics
  # Proc stored to soft quit
  @on_close = proc {
    if $scene.is_a?(GamePlay::Base) || $scene.is_a?(Scene_Map) || $scene.is_a?(Scene_Battle)
      # Tell the GamePlay::Base scene to quit
      $scene.instance_variable_set(:@running, false)
      # Tell main not to continue to update (& Scene_Map to quit)
      $scene = nil
      @soft_quitting = true
      next(false) # Prevent the game from quitting
    end
    next(!@soft_quitting)
  }
end
=end
