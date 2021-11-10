# The purpose of this file is to fix binary file in order to ensure PSDK will run properly
renamer = proc do |filename|
  new_filename = filename.sub('.update', '')
  File.rename(filename, new_filename)
rescue Errno::EACCES
  File.rename(new_filename, "#{new_filename}.old")
  retry
end
Dir['lib/*.update'].each(&renamer)
Dir['ruby_builtin_dlls/*.update'].each(&renamer)

deleter = proc do |filename|
  File.delete(filename)
rescue Errno::EACCES
  puts "Failed to delete #{filename}"
end
Dir['lib/*.old'].each(&deleter)
Dir['ruby_builtin_dlls/*.old'].each(&deleter)
