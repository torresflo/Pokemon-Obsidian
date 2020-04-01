print "Enter the new folder to check : "
src = STDIN.gets.chomp.gsub('"','').gsub("\\",'/') + '/'
print "Enter the old folder to check : "
dest = STDIN.gets.chomp.gsub('"','').gsub("\\",'/') + '/'
src.gsub!('//','/')
dest.gsub!('//','/')

def explore_folder(src_path, part_to_remove, dest_path)
  folders = Dir[src_path + '*/']
  folders.each do |folder|
    explore_folder(folder, part_to_remove, dest_path)
  end
  Dir[src_path + '*.*'].each do |filename|
    clean = filename.sub(part_to_remove, '')
    dest_filename = dest_path + clean
    show_clean = !File.exist?(dest_filename)
    show_clean ||= File.size(dest_filename) != File.size(filename)
    show_clean ||= File.binread(dest_filename) != File.binread(filename)
    if show_clean
      puts clean
    end
  end
end

explore_folder(src, src, dest)
print "Press Enter..."
STDIN.gets