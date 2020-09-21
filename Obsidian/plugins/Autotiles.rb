#encoding: utf-8

#> Prevent the game from launching
$GAME_LOOP = proc {}

file_list = Dir['graphics/autotiles/*.png']
file_list -= (tiled = Dir['graphics/autotiles/*_._tiled.png']).collect { |fn| fn.gsub('_._tiled.png', '.png') }
file_list -= tiled
file_list -= Dir['graphics/autotiles/z_*.png']
file_list.each do |fn|
  puts "Converting #{fn}..."
  Converter.convert_autotile(fn)
end
puts 'File converted !'