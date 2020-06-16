need_to_open_window = true
rgss_main do
  if need_to_open_window
    Graphics.start
  else
    Graphics.init_sprite
    Graphics.frame_reset
  end
  need_to_open_window = false
  # Check project integrity
  puts 'Some resources of your project are missing!' unless File.exist?('audio/se/cries/001cry.wav')
  GC.start
  # Prepare for transition
  Graphics.freeze
  $scene = Scheduler.get_boot_scene
  # Call main method as long as $scene is effective
  $scene.main until $scene.nil?
  Graphics.transition(20)
  Graphics.stop
rescue Exception
  Graphics.stop if $!.class != LiteRGSS::Graphics::ClosedWindowError && $!.class.to_s != 'Reset'
  if Object.const_defined?(:Yuki) && Yuki.const_defined?(:EXC)
    Yuki::EXC.run($!)
  else
    raise
  end
end
