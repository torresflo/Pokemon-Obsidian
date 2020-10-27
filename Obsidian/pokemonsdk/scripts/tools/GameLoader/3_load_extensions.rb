# Load the extensions
begin
  $DEBUG = false
  ENV['__GL_THREADED_OPTIMIZATIONS'] = '0'
  require 'zlib'
  require 'socket'
  require 'uri'
  require 'openssl'
  require 'net/http'
  require 'csv'
  require 'json'
  require 'yaml'
  require 'rexml/document'
  require PSDK_RUNNING_UNDER_WINDOWS ? './lib/LiteRGSS.so' : 'LiteRGSS'
  # Attempt to load audio
  begin
    require PSDK_RUNNING_UNDER_WINDOWS ? './lib/RubyFmod.so' : 'RubyFmod'
  rescue LoadError
    begin
      require PSDK_RUNNING_UNDER_WINDOWS ? './lib/SFMLAudio.so' : 'SFMLAudio'
    rescue LoadError
      puts 'Could not load Audio'
    end
  end
rescue LoadError
  display_game_exception('An error occured during extensions loading.')
end

# Class that describe a Color (compatibility with RGSS load data)
class ::Color < LiteRGSS::Color
  # Do nothing
end

# Class that describe a Tone (compatibility with RGSS load data)
class ::Tone < LiteRGSS::Tone
  # Do nothing
end

# Include all the liteRGSS classes to the current module
include LiteRGSS

# Store the RGSS Main entry function
def rgss_main
  $GAME_LOOP = proc do
    yield
  rescue StandardError => e
    if e.class.to_s == 'Reset'
      $scene.main if $scene.is_a?(Yuki::SoftReset)
      retry
    end
  end
end
