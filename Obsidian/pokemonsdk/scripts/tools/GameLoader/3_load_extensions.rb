# Load the extensions
begin
  $DEBUG = false
  STDERR.reopen(IO::NULL) if File.exist?('Data/Scripts.dat') # This should remove SFML messages (most of the time they're success)
  ENV['__GL_THREADED_OPTIMIZATIONS'] = '0'
  require 'zlib'
  require 'socket'
  require 'uri'
  require 'openssl'
  require 'net/http'
  require 'csv'
  require 'json'
  require 'yaml'
  game_deps = ENV['GAMEDEPS'] || '.'
  # require 'rexml/document'
  require PSDK_RUNNING_UNDER_WINDOWS ? "#{game_deps}/lib/LiteRGSS.so" : './LiteRGSS'
  # Attempt to load audio
  begin
    require PSDK_RUNNING_UNDER_WINDOWS ? "#{game_deps}/lib/RubyFmod.so" : './RubyFmod'
  rescue LoadError
    begin
      require PSDK_RUNNING_UNDER_WINDOWS ? "#{game_deps}/lib/SFMLAudio.so" : './SFMLAudio'
    rescue LoadError
      puts 'Could not load Audio'
    end
  end
rescue LoadError
  display_game_exception('An error occured during extensions loading.')
end

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
