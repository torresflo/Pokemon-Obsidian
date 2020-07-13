def save
  File.open(__FILE__.gsub(".rb",".dat"), "wb") do |f|
    Marshal.dump($data, f)
  end
end
begin
  include Math

  $data = {
    :origin => [],
    #:global => [],
    :target => [],
  }
  
  trainer_height = 60
  time_of_flight = 15
  
  origin = $data[:origin]
  target = $data[:target]
  
  # Create the ball sprite animation copy
  origin << [:spawn_sprite, 0]
  origin << [:set_property, 0, {z: 10}]
  origin << [:advance, 0, 0, 1000] # Set the sprite at the original position
  origin << [:move, 0, 0, 6]
  origin << [:load_parameter, :ball_sprite] # Load the ball sprite
  origin << [:copy_bitmap, 0, false] # Copy the ball sprite image
  origin << [:set_src_rect, 0, 0, 26 * 13, 16, 26]
  origin << [:set_sprite_origin_div, 0, 2, 1]
  origin << :synchronize
  target << [:spawn_sprite, 0]
  target << [:set_property, false, {visible: false}]
  target << [:copy_bitmap, 0, false, true]
  target << [:set_property, 0, {zoom: 0}]
  target << :synchronize
  
  movement_wait = 6
  
  total_wait = movement_wait
  origin << [:set_src_rect, 0, 0, 26 * 5]
  origin << [:waitcounter, total_wait]
  target << [:se_play, 'pokeopenbreak']
  (unzoom_time = 20).times do |i|
    target << [:set_property, 0, {zoom: (i + 1) / 20.0}]
    target << :synchronize
  end
  origin << [:waitcounter, total_wait += unzoom_time]
  target << [:waitcounter, total_wait]
  target << [:set_property, false, {visible: true}]
  target << :synchronize
  origin << [:terminate]
  origin << :synchronize
  
  save
rescue Exception
  puts $!.class
  puts $!.message
  puts $!.backtrace.join("\n")
  system("pause")
end