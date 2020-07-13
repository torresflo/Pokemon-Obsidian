def save
  File.open(__FILE__.gsub(".rb",".dat"), "wb") do |f|
    Marshal.dump($data, f)
  end
end
begin
  $data = {
    :origin => [],
    #:global => [],
    :target => [],
  }
  
  origin = $data[:origin]
  target = $data[:target]
  
  origin << [:spawn_sprite, 0]
  target << [:spawn_sprite, 0, [[:visible, false]]]
  origin << [:copy_bitmap, 0, nil, true]
  origin << [:set_property, nil , [[:visible, false]]]
  target << [:load_bitmap, 0, :animation, "charge", 0]
  target << [:center, 0]
  target << [:set_sprite_origin_div,0 , 2, 2]
  target << [:waitcounter, 10]
  10.times do |i|
    origin << [:advance, 0, 0, (i+1)*2]
    origin << :synchronize
  end
  target << [:se_play, "hit", 50, 150]
  target << [:set_property, 0 , [[:visible, true]]]
  target << :synchronize
  20.times do |i|
    target << [:set_property, 0 , [[:opacity, (20-i)*255/20]]]
    target << :synchronize
    origin << [:advance, 0, 0, 19-i]
    origin << :synchronize
  end
  
  origin << [:set_property, nil , [[:visible, true]]]
  origin << [:terminate]
  origin << :synchronize
  
  save
rescue Exception
  puts $!.class
  puts $!.message
  puts $!.backtrace.join("\n")
  system("pause")
end