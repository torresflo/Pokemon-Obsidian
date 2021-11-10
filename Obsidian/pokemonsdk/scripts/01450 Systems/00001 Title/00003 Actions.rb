class Scene_Title
  private

  def action_a
    if @title_controls.index == 0
      Graphics.update until all_data_loaded?
      action_play_game
    else
      action_show_credits
    end
  end

  def action_up
    return play_buzzer_se if @title_controls.index == 0

    play_cursor_se
    @title_controls.index = 0
  end

  def action_down
    return play_buzzer_se if @title_controls.index == 1

    play_cursor_se
    @title_controls.index = 1
  end

  def action_play_game
    Yuki::MapLinker.reset
    Audio.bgm_stop
    $scene = GamePlay::Load.new
    if $scene.should_make_new_game?
      self.visible = false
      $scene.create_new_game
    end
    @running = false
  end

  def action_show_credits
    $scene = GamePlay::CreditScene.new
    @running = false
  end
end
