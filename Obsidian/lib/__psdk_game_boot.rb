# File that ensure the Boot works well

# Constant telling PSDK runs under windows
PSDK_RUNNING_UNDER_WINDOWS = !ENV['windir'].nil?

# Constant telling where is the PSDK master installation
PSDK_PATH = Dir.exist?('pokemonsdk') ? 'pokemonsdk' : ((ENV['APPDATA'] || ENV['HOME']).dup.force_encoding('UTF-8') + '/.pokemonsdk')

# Update fix
Dir['lib/*.update'].each { |filename| File.rename(filename, filename.sub('.update','')) }

# Variable that holds the boot time
boot_time = Time.new

# Adjust load path
paths = $LOAD_PATH[0, 10]
$LOAD_PATH.clear
$LOAD_PATH.concat(paths.collect { |path| path.dup.force_encoding('UTF-8').freeze })
# Add . and ./plugins to load_path
$LOAD_PATH << '.' unless $LOAD_PATH.include?('.')
$LOAD_PATH << './plugins' unless $LOAD_PATH.include?('./plugins')

# Function that display an exception with a message and clean up
# @param message [String] message for the exception
def display_game_exception(message)
  puts message
  puts format('Error type : %<class>s', class: $!.class)
  puts format('Error message : %<message>s', message: $!.message)
  puts $!.backtrace
  Audio.bgm_stop rescue nil
  Audio.bgs_stop rescue nil
  Audio.me_stop rescue nil
  Audio.se_stop rescue nil
  FMOD::System.close rescue nil
  exit!
end

# Parse the arguments
require './lib/__parse_argments'

# Load the extensions
begin
  require 'zlib'
  require 'socket'
  require PSDK_RUNNING_UNDER_WINDOWS ? './lib/LiteRGSS.so' : 'LiteRGSS'
  require PSDK_RUNNING_UNDER_WINDOWS ? './lib/RubyFmod.so' : 'RubyFmod'
rescue StandardError
  display_game_exception('An error occured during extensions loading.')
end


# Class that describe a Color (compatibility with RGSS load data)
class ::Color < LiteRGSS::Color
  
end

# Class that describe a Tone (compatibility with RGSS load data)
class ::Tone < LiteRGSS::Tone
  
end

# Include all the liteRGSS classes to the current module
include LiteRGSS

# Load data from a file
# @param filename [String] name of the file where to load the data
# @return [Object]
def load_data(filename)
  Marshal.load(File.binread(filename))
end

# Save data to a file
# @param data [Object] data to save to a file
# @param filename [String] name of the file
def save_data(data, filename)
  File.binwrite(filename, Marshal.dump(data))
  return nil
end

# Loading all the game scripts
begin
  puts 'Loading Game...'
  load_data('Data/Scripts.rxdata').each do |script|
    eval(Zlib::Inflate.inflate(script[2]).force_encoding(Encoding::UTF_8), binding, script[1].force_encoding(Encoding::UTF_8))
    GC.start
  end
  GC.start
rescue StandardError
  display_game_exception('An error occured during Script Loading.')
end

# Loading all the utility
begin
  PARGV[:util].to_a.each do |filename|
    require filename
  end
rescue StandardError
  display_game_exception('An error occured during Utility loading...')
end

# Actually start the game
begin
  puts format('Time to boot game : %<time>ss', time: (Time.new - boot_time))
  $GAME_LOOP.call
rescue Exception
  display_game_exception('An error occured during Game Loop.')
end