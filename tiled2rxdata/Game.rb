if ARGV.first == 'gem'
  require './lib/__gem.rb'
elsif ARGV.first == 'bundle'
  require './lib/__bundle.rb'
else
  require './lib/__psdk_game_boot.rb'
end