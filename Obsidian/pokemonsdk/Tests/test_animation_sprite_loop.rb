def test_animation_loop
  # Defining the animated resources
  vp = Viewport.create(:main, 5000)
  sp = SpriteSheet.new(vp, 4, 4)
  sp.set_bitmap('Doors_3', :character)
  # Create the animation and retreive the root
  animation = Yuki::Animation.instance_eval {
    run_commands_during(0.5, 
      send_command_to(sp, :select, 0, 0),
      send_command_to(sp, :select, 1, 0),
      send_command_to(sp, :select, 2, 0),
      send_command_to(sp, :select, 3, 0),
      send_command_to(sp, :select, 0, 1),
      send_command_to(sp, :select, 1, 1),
      send_command_to(sp, :select, 2, 1),
      send_command_to(sp, :select, 3, 1)
    ) > se_play('nintendo') > wait(1)
  }.root
  looped_animation = Yuki::Animation::TimedLoopAnimation.new(1.5)
  looped_animation.play_before(animation)
  animation = Yuki::Animation::TimedAnimation.new(6)
  animation.parallel_play(looped_animation)
  animation.start
  # Process the animation
  until animation.done?
    animation.update
    Graphics.update
  end
  vp.dispose
end