# The purpose of this file is to fix binary file in order to ensure PSDK will run properly
Dir['lib/*.update'].each { |filename| File.rename(filename, filename.sub('.update', '')) }
