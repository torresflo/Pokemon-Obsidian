pcc "Warning this script will replace the 50 first common event of your Game with those from PSDK Alpha 24.20", 2
print "Do you want to update the game to PSDK Alpha 24.20 ? [yes/no] "
res = STDIN.gets.chomp.downcase
if res == "yes"
  puts "Copying common events..."
  src = load_data('plugins/CommonEvents.rxdata')
  dest = load_data('Data/CommonEvents.rxdata')
  1.upto(50) do |i|
    dest[i] = src[i]
  end
  save_data(dest, 'Data/CommonEvents.rxdata')
  
  puts "Erasing the update files..."
  ['plugins/CommonEvents.rxdata', 'plugins/update_24_20.rb'].each { |fn| File.delete(fn) }
end
$GAME_LOOP = proc {}