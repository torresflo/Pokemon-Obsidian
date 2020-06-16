# Constant telling PSDK runs under windows
PSDK_RUNNING_UNDER_WINDOWS = !ENV['windir'].nil?
# Constant telling where is the PSDK master installation
PSDK_PATH = (Dir.exist?('pokemonsdk') && 'pokemonsdk') ||
            ((ENV['APPDATA'] || ENV['HOME']).dup.force_encoding('UTF-8') + '/.pokemonsdk')

# Fix $LOAD_PATH
paths = $LOAD_PATH[0, 10]
$LOAD_PATH.clear
$LOAD_PATH.concat(paths.collect { |path| path.dup.force_encoding('UTF-8').freeze })
# Add . and ./plugins to load_path
$LOAD_PATH << '.' unless $LOAD_PATH.include?('.')
$LOAD_PATH << './plugins' unless $LOAD_PATH.include?('./plugins')

ENV['SSL_CERT_FILE'] ||= './lib/cert.pem' if $0 == 'Game.rb' # Launched from PSDK

begin
  PSDK_Version = File.read("#{PSDK_PATH}/version.txt").to_i
rescue Exception
  puts('Failed to load PSDK Version')
  PSDK_Version = 6197
end
# Display PSDK version
puts("\e[31mPSDK Version : #{[PSDK_Version].pack('I>').unpack('C*').join('.')}\e[37m")
