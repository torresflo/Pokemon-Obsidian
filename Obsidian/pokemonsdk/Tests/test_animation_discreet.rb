def test_animation_discreet
  # Defining the animated resources
  vp = Viewport.create(:main, 5000)
  sprite = Sprite.new(vp)
  sprite.bitmap = RPG::Cache.character('Doors_3')
  sprite.src_rect.set(0, 0, 16, 16)
  # Defining the data for the serialized animation
  resolver_data = {
    sprite: sprite,
    sprite_rect: sprite.src_rect,
    distortion_proc: proc { |x| (x * 2) % 1 }
  }
  # Transform it into a "resolver" for the animation processor
  resolver = resolver_data.method(:fetch)
  # Create the animation and retreive the root
  animation = Yuki::Animation.instance_eval {
    cell_y_change(0.5, :sprite_rect, 0, 1, 16) |
    cell_x_change(0.5, :sprite_rect, 0, 3, 16, distortion: :distortion_proc)
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
end