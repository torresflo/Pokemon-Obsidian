require 'uri'
require 'zlib'
p RUBY_VERSION
system("git log --oneline")
print("Enter commit short sha1 : ")
sha1 = STDIN.gets.chomp
files = []
IO.popen("git diff #{sha1} --name-only") do |f|
  while line = f.gets
    if line.start_with?('scripts/') && !File.directory?(line.chomp)
      files << line.chomp
    end
  end
end
puts files

print "Update LiteRGSS ? Y/N (N) :"
update_litergss = STDIN.gets.downcase.start_with?('y')
print "Update RubyFmod ? Y/N (N) :"
update_rubyfmod = STDIN.gets.downcase.start_with?('y')

psdk_path = File.basename(File.expand_path('.'))

version = File.read('version.txt').to_i

Dir.chdir('..')
Dir.mkdir('psdk_update') unless Dir.exist?(update_path = 'psdk_update')
update_path << "/#{version}"
Dir.mkdir(update_path) unless Dir.exist?(update_path)


UPDATE_PATH = update_path
def copy_file(filename, update_path = UPDATE_PATH)
  target_filename = File.join(update_path, File.basename(filename))
  File.copy_stream(filename, target_filename)
end


update_file_contents = "PSDK_INDEX_DOWNLOAD
"
puts "Copying PSDK scripts..."
# add
psdk_base_path = File.basename(psdk_path)
mega_script_arch = {}
sc_load = 'scripts/ScriptLoad.rb'
files.each do |filename|
  if filename == sc_load
    update_file_contents << "ScriptLoad.rb:%PSDK%/#{filename}\n"
    copy_file(File.join(psdk_path, filename))
    next
  end
  real_filename = File.join(psdk_base_path, filename)
  if File.exist?(real_filename)
    mega_script_arch[real_filename] = File.binread(real_filename)
  end
end
update_file_contents << "mega_script.deflate:%PSDK%/scripts/mega_script.deflate\n"
File.binwrite(File.join(UPDATE_PATH, 'mega_script.deflate'), Zlib::Deflate.deflate(Marshal.dump(mega_script_arch)))
=begin
files.each do |filename|
  if File.exist?(File.join(psdk_path, filename))
    basename = File.basename(filename)
    update_file_contents << "#{URI.encode(basename)}:%PSDK%/#{filename}\n"
    copy_file(File.join(psdk_path, filename))
  end
end
=end

current_path = File.expand_path('.') + '/'
print 'Additionnal ressource : '
while (line = STDIN.gets.chomp).bytesize > 0
  line.gsub!("\\",'/')
  line.delete!('"')
  line.gsub!(current_path, '')
  copy_file(line)
  update_file_contents << "#{URI.encode_www_form_component(File.basename(line))}:#{line}\n"
  print 'Additionnal ressource : '
end

if update_litergss
  copy_file('lib/LiteRGSS.so')
  update_file_contents << "LiteRGSS.so:lib/LiteRGSS.so.update\n"
end

if update_rubyfmod
  copy_file('lib/RubyFmod.so')
  update_file_contents << "RubyFmod.so:lib/RubyFmod.so.update\n"
end

# Copy version & finalize
File.write(File.join(psdk_path, 'version.txt'), version.next.to_s)
File.write(File.join(update_path, 'version.txt'), version.next.to_s)
update_file_contents << 'version.txt:version.txt'
File.write(File.join(update_path, 'file_index.txt'), update_file_contents)

puts "Press enter..."
STDIN.gets