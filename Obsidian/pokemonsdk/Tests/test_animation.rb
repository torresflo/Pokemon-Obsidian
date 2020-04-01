def test_animation
  # Defining the animated resources
  vp = Viewport.create(:main, 5000)
  sprite = Sprite.new(vp)
  sprite.bitmap = RPG::Cache.character('005_0')
  sprite.src_rect.set(0, 0, 32, 32)
  sprite.set_origin(16, 16)
  # Defining the data for the serialized animation
  resolver_data = {
    sprite: sprite,
    sprite_rect: sprite.src_rect,
    angle_begin: 0,
    angle_end: 3600,
    frame_begin: 0,
    frame_end: 3,
    frame_width: 32,
    distortion_proc: proc { |x| (x * 40) % 1 }
  }
  # Transform it into a "resolver" for the animation processor
  resolver = resolver_data.method(:fetch)
  # Create the animation and retreive the root
  animation = Yuki::Animation.instance_eval {
    rotation(10, :sprite, :angle_begin, :angle_end, distortion: :SMOOTH_DISTORTION) |
    cell_x_change(10, :sprite_rect, :frame_begin, :frame_end, :frame_width, distortion: :distortion_proc) |
    move(10, :sprite,
      16, 16, 320 - 16, 16) > # startx, starty, endx, endy
    move(10, :sprite,
      320 - 16, 16, 16, 16) | cell_x_change(10, :sprite_rect, :frame_begin, :frame_end, :frame_width, distortion: :distortion_proc)
  }.root
  # Save it into a file (so we can reuse it latter, that's why we need a resolver)
  save_data(animation, 'test_anim.rxdata')
  # Set the animation resolver & start it
  animation.resolver = resolver
  animation.start
  # Process the animation
  until animation.done?
    animation.update
    Graphics.update
  end
end