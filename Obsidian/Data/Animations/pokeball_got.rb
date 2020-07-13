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
  origin << [:set_property, 0, {z: 9_999}]
  origin << [:advance, 0, 0, 1000] # Set the sprite at the original position
  origin << [:move, 0, 0, 6]
  origin << [:load_parameter, :ball_sprite] # Load the ball sprite
  origin << [:copy_bitmap, 0, false] # Copy the ball sprite image
  origin << [:set_src_rect, 0, 0, 26 * 13, 16, 26]
  origin << [:set_sprite_origin_div, 0, 2, 1]
  origin << :synchronize
  target << [:set_property, false, {visible: false}]
  target << :synchronize
  
  movement_wait = 6
  
  total_wait = movement_wait
  origin << [:waitcounter, total_wait]
  origin << [:set_src_rect, 0, 0, 26 * 15]
  origin << [:waitcounter, total_wait += movement_wait]
  origin << [:se_play, 'hitlow', 60, 150]
  origin << [:set_src_rect, 0, 0, 26 * 16]
  origin << [:waitcounter, total_wait += movement_wait]

  suspence_time = 30
  origin << [:waitcounter, total_wait += suspence_time]
  target << [:waitcounter, total_wait]
  origin << [:load_parameter, :ball_sprite] # Load the ball sprite
  origin << [:copy_bitmap, false, 0, true] # Set the ball sprite coordinates
  origin << [:set_property, false, {visible: true}]
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