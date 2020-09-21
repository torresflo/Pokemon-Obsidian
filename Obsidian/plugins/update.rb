#encoding: utf-8
require 'net/http'
require 'uri'

#> Prevent the game from launching
$GAME_LOOP = proc {}
#> Making base directory
Dir.mkdir(PSDK_PATH) unless Dir.exist?(PSDK_PATH)
PSDK_MASTER = PSDK_PATH + '/master'
Dir.mkdir(PSDK_MASTER) unless Dir.exist?(PSDK_MASTER)
psdk_data = PSDK_PATH + '/Data'
Dir.mkdir(psdk_data) unless Dir.exist?(psdk_data)

BASE_URL = 'https://download.psdk.pokemonworkshop.com/downloads/'
begin
  BASE_VERSION = (File.open(PSDK_PATH + '/version.txt') { |f| f.read }).to_i
rescue
  BASE_VERSION = 5378
end

# Download the file index
# @param version [Integer] the current PSDK version
# @return [Hash, nil] if failure, return nil
# @note Return hash associate a file to download to a file to store on the computer
def download_index(version)
  uri = URI(BASE_URL + "#{version}/file_index.txt")
  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, ca_file: './lib/cert.pem') {|http|
    http.request(Net::HTTP::Get.new(uri))
  }
  return nil unless response.code.to_i == 200
  parse_index(response.body)
end
# Parse the index
# @param str [String] real index that should start with "PSDK_INDEX_DOWNLOAD\r\n"
# @return [Hash, nil] if bad index, return nil
def parse_index(str)
  arr = str.split("\r\n")
  return nil if arr.shift != 'PSDK_INDEX_DOWNLOAD'
  hash = {}
  arr.each do |line|
    src, dest = line.split(':')
    if dest.gsub!('%PSDK%', PSDK_PATH) and PSDK_Version < BASE_VERSION
      puts "#{dest} ignored due to higher version of shared PSDK engine !"
      next
    end
    hash[src] = dest
  end
  return hash
end
# Download a file and save it
# @param src [String] SRC URL of the file to download
# @param dest [String] the destination filename
# @return [Boolean] if the operation was a success
def download_file(src, dest)
  uri = URI(src)
  print "Requesting #{dest}\r"
  Net::HTTP.start(uri.host, uri.port, use_ssl: true, ca_file: './lib/cert.pem') do |http|
    request = Net::HTTP::Get.new uri
    http.request request do |response|
      return false if response.code.to_i != 200
      read = 0
      length = response.content_length
      base_dir = File.dirname(dest)
      Dir.mkdir!(base_dir) unless Dir.exist?(base_dir)
      File.open(dest, 'wb') do |f|
        puts "Downloading #{dest}"
        t = Time.new
        response.read_body do |chunk|
          read += chunk.bytesize
          print "\r[", ("=" * (read * 10 / length)).ljust(10), '] '
          print (read * 100 / length).to_s.rjust(3), '% '
          print length / 1024, 'Ko '
          print (chunk.bytesize / (Time.new - t) / 1024).to_s.to_i, 'Ko/s        '
          t = Time.new
          f.write chunk
        end
      end
      print "\n"
      return true
    end
  end
  return false
end
# Download an update for a specific version
# @param version [Integer] the current PSDK version
# @return [Boolean] if the operation was a success
def download_update(version)
  index = download_index(version)
  unless index
    puts "No update for this version..." if version == PSDK_Version
    return false
  end
  index.each do |src, dest|
    unless download_file(BASE_URL + "#{version}/#{src}", dest)
      puts "Failed to download #{dest}"
      return false
    end
  end
  return true
end
puts "Checking for updates for this version..."
if download_update(PSDK_Version)
  puts "Updated success !"
  loop do
    ScriptLoader.unpack_scripts if File.exist?(ScriptLoader::DEFLATE_SCRIPT_PATH)
    version = (File.open("version.txt") { |f| f.read }).to_i
    break if version == PSDK_Version # Prevent from downloading update twice
    break unless download_update(version)
  end
  #> Copy the current version to the master version
  version = File.open("version.txt") { |f| f.read }
  File.open(PSDK_PATH + '/version.txt', 'wb') { |f| f << version }
end