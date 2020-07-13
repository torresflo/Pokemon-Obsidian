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
  
  origin << [:spawn_sprite, 0]
  origin << [:load_bitmap, 0, :animation, "shiny", 0]
  origin << [:set_src_rect, 0, 0, 0, 49, 49]
  origin << [:set_sprite_origin_div,0 , 2, 2]
  origin << [:center, 0]
  origin << [:se_play, "055-Right01", 80, 150]
  5.times do |j|
    10.times do |i|
      origin << [:set_src_rect, 0, 49 * i, 49*j, 49, 49]
      origin << :synchronize
    end
  end
  origin << [:terminate]
  origin << :synchronize
  
  save
rescue Exception
  puts $!.class
  puts $!.message
  puts $!.backtrace.join("\n")
  system("pause")
end