# module Kernel
  # alias_method :old_require, :require
  # def require(str)
    # old_require(str)
  # rescue LoadError
    # STDERR << "Yuri : failed to load #{str}\n"
  # end
# end
if ARGV.first == 'gem'
  require './lib/__gem.rb'
elsif ARGV.first == 'bundle'
  require './lib/__bundle.rb'
else
  psdk_path = (Dir.exist?('pokemonsdk') && 'pokemonsdk') || ((ENV['APPDATA'] || ENV['HOME']).dup.force_encoding('UTF-8') + '/.pokemonsdk')
  require "#{psdk_path}/scripts/ScriptLoad.rb"
  ScriptLoader.load_tool('GameLoader/Z_load_uncompiled')
end