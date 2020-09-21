#encoding: utf-8
print "\e[37m\e[40m"
puts " PSDK Help ".center(80, "=")
puts "List of arguments".ljust(80)
puts "  Screen Properties :".ljust(80)
puts "=>  \e[36m--scale=n\e[37m change the screen scale, default 2, min 1, max 4".ljust(80 + 10)
puts "=>  \e[36m--smooth\e[37m use smooth texture zooming instead of nearest texture zooming".ljust(80 + 10)
puts "=>  \e[36m--fullscreen\e[37m show game in fullscreen".ljust(80 + 10)
puts "=>  \e[36m--no-vsync\e[37m Use framelimit instead of VSYNC.".ljust(80 + 10)
puts "=>  \e[36m--hide-fps\e[37m Hide the FPS counter.".ljust(80 + 10)
puts "  Specific commands :".ljust(80)
puts "=>  \e[36m--test=scriptname\e[37m Test a specific script".ljust(80 + 10)
puts "=>  \e[36m--util=scriptname\e[37m Load a specific util script from plugins".ljust(80 + 10)
puts "=>  \e[36m--util=autotiles.rb\e[37m Convert RMXP autotiles to PSDK autotiles".ljust(80 + 10)
puts "      Note : Does not convert already converted autotiles or files starting by z_".ljust(80 + 10)
puts "=>  \e[36m--animation-editor\e[37m Start the animation editor".ljust(80 + 10)
puts "=>  \e[36m--worldmap\e[37m Start the world map editor".ljust(80 + 10)
exit