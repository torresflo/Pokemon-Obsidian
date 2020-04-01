# Load the extensions
begin
  $DEBUG = false
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
  require PSDK_RUNNING_UNDER_WINDOWS ? './lib/RubyFmod.so' : 'RubyFmod'
rescue StandardError
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
