def test_animation_sprite
  # Defining the animated resources
  vp = Viewport.create(:main, 5000)
  # sprite = Sprite.new(vp)
  # sprite.bitmap = RPG::Cache.character('Doors_3')
  # sprite.src_rect.set(0, 0, 16, 16)
  # Defining the data for the serialized animation
  resolver_data = {
    main: vp
  }
  # Transform it into a "resolver" for the animation processor
  resolver = resolver_data.method(:fetch)
  # Create the animation and retreive the root
  animation = Yuki::Animation.instance_eval {
    run_commands_during(0.5, 
      create_sprite(:main, :test, SpriteSheet, [4, 4], [:set_bitmap, 'Doors_3', :character], [:select, 0, 0]),
      send_command_to(:test, :select, 1, 0),
      send_command_to(:test, :select, 2, 0),
      send_command_to(:test, :select, 3, 0),
      send_command_to(:test, :select, 0, 1),
      send_command_to(:test, :select, 1, 1),
      send_command_to(:test, :select, 2, 1),
      send_command_to(:test, :select, 3, 1)
    ) > dispose_sprite(:test) > se_play('Nintendo') > wait(1)
  }.root
  # Save it into a file (so we can reuse it latter, that's why we need a resolver)
  # save_data(animation, 'test_anim.rxdata')
  # Set the animation resolver & start it
  animation.resolver = resolver
  animation.start
  # Process the animation
  until animation.done?
    animation.update
    Graphics.update
  end
  vp.dispose
end