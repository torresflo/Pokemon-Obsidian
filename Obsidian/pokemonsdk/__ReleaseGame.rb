{ARGUMENT_PARSE}

# Constant telling PSDK runs under windows
PSDK_RUNNING_UNDER_WINDOWS = !ENV['windir'].nil?

# Constant telling where is the PSDK master installation
PSDK_PATH = Dir.exist?('pokemonsdk') ? 'pokemonsdk' : ((ENV['APPDATA'] || ENV['HOME']).dup.force_encoding('UTF-8') + '/.pokemonsdk')

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
# @param utf8 [Boolean] if the utf8 conversion should be done
# @return [Object]
def load_data(filename, utf8 = false)
  if filename.start_with?('Data/Map')
    return load_data_vd(filename, 'Data/1.dat', utf8)
  elsif filename.start_with?('Data/Text')
    return load_data_vd(filename, 'Data/2.dat', utf8)
  elsif filename.start_with?('Data/PSDK')
    return load_data_vd(filename, 'Data/3.dat', utf8)
  elsif filename.start_with?('Data/Animations/')
    return load_data_vd(filename, 'Data/4.dat', utf8)
  elsif filename.start_with?('Data/')
    return load_data_vd(filename, 'Data/0.dat', utf8)
  end
  Marshal.load(File.binread(filename))
end

::Kernel::Loaded = {}

# Load the file from the Yuki::VD file
# @param filename [String] name of the file where to load the data
# @param vdfilename [String] name of the Yuki::VD file
# @param utf8 [Boolean] if the utf8 conversion should be done
def load_data_vd(filename, vdfilename, utf8 = false)
  unless ::Kernel::Loaded.has_key?(vdfilename)
    ::Kernel::Loaded[vdfilename] = Yuki::VD.new(vdfilename, :read)
  end
  # puts "#{filename}, #{vdfilename}, #{utf8}, #{::Kernel::Loaded[vdfilename].exists?(File.basename(filename).downcase)}"
  unless utf8
    return Marshal.load(::Kernel::Loaded[vdfilename].read_data(File.basename(filename).downcase))
  end
  Marshal.load(::Kernel::Loaded[vdfilename].read_data(File.basename(filename).downcase), proc {|o| o.force_encoding(Encoding::UTF_8) if o.class == String; next(o) })
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
  scripts = Marshal.load(Zlib::Inflate.inflate(File.binread('Data/Scripts.dat')))
  scripts.each { |script| RubyVM::InstructionSequence.load_from_binary(script).eval }
  scripts = nil
  GC.start
rescue StandardError
  display_game_exception('An error occured during Script Loading.')
end

puts format('Time to boot game : %<time>ss', time: (Time.new - boot_time))