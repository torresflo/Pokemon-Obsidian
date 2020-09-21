pcc "Warning this script will replace the 50 first common event of your Game with those from PSDK Alpha 24", 2
pcc "This script will also edit the 100 first switch and variables of your game", 2
print "Do you want to update the game to PSDK Alpha 24.11 ? [yes/no] "
res = STDIN.gets.chomp.downcase
if res == "yes"
  puts "Copying common events..."
  src = load_data('plugins/CommonEvents.rxdata')
  dest = load_data('Data/CommonEvents.rxdata')
  1.upto(50) do |i|
    dest[i] = src[i]
  end
  save_data(dest, 'Data/CommonEvents.rxdata')
  
  puts "Copying switches & variables"
  src = load_data('plugins/System.rxdata')
  dest = load_data('Data/System.rxdata')
  1.upto(100) do |i|
    dest.switches[i] = src.switches[i]
    dest.variables[i] = src.variables[i]
  end
  save_data(dest, 'Data/System.rxdata')
  
  print "Do you want to update the system tags for the 6th tileset ? [yes/no] "
  res = STDIN.gets.chomp.downcase
  if res == "yes"
    src = load_data('plugins/SystemTags.rxdata')
    dest = load_data('Data/PSDK/SystemTags.rxdata')
    dest[6] = src[6]
    save_data(dest, 'Data/PSDK/SystemTags.rxdata')
  end
  
  puts "Erasing the update files..."
  ['plugins/CommonEvents.rxdata', 'plugins/System.rxdata', 'plugins/SystemTags.rxdata', 'plugins/update_24.rb'].each { |fn| File.delete(fn) }
end
$GAME_LOOP = proc {}