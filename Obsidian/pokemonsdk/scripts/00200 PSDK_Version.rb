#encoding: utf-8

begin
  File.open("#{PSDK_PATH}/version.txt") do |f|
    PSDK_Version = f.read(f.size).to_i
  end
rescue Exception
  puts("Failed to load PSDK Version")
  PSDK_Version = 5378
end
# Version of the Game (Defined by Maker and should be increase for each release)
Game_Version = 256
# Display PSDK version
version = [PSDK_Version].pack('I>').unpack('C*')
if version.first == 0
  if version[1] == 0
    version_string = "Alpha #{version[2,2].join('.')}"
  else
    version_string = "Bêta #{version[1,3].join('.')}"
  end
else
  version_string = version.join('.')
end
puts("\e[31mPSDK Version : #{version_string}\e[37m")
