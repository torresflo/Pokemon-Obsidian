# Constant telling PSDK runs under windows
PSDK_RUNNING_UNDER_WINDOWS = !ENV['windir'].nil?

# Constant telling PSDK runs under mac
PSDK_RUNNING_UNDER_MAC = RUBY_PLATFORM.include? "darwin"

# Constant telling where is the PSDK master installation
PSDK_PATH = (Dir.exist?('pokemonsdk') && File.expand_path('pokemonsdk')) ||
            ((ENV['APPDATA'] || ENV['HOME']).dup.force_encoding('UTF-8') + '/.pokemonsdk')

# Fix $LOAD_PATH
# paths = $LOAD_PATH[0, 10]
# $LOAD_PATH.clear
# $LOAD_PATH.concat(paths.collect { |path| path.dup.force_encoding('UTF-8').freeze })
# Add . and ./plugins to load_path
# $LOAD_PATH << '.' unless $LOAD_PATH.include?('.')
$LOAD_PATH << './plugins' unless $LOAD_PATH.include?('./plugins')

ENV['SSL_CERT_FILE'] ||= './lib/cert.pem' if $0 == 'Game.rb' # Launched from PSDK

begin
  PSDK_Version = File.read("#{PSDK_PATH}/version.txt").to_i
rescue Exception
  puts('Failed to load PSDK Version')
  PSDK_Version = 6401
end
# Display PSDK version
arr = [PSDK_Version].pack('I>').unpack('C*')
puts("\e[31mPSDK Version : #{arr.join('.').gsub(/^(0\.)+/, '')}\e[37m") # [PSDK_Version].pack('I>').unpack('C*').join('.')
