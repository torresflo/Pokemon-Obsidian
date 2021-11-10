lf = $LOADED_FEATURES.reject { |feature| feature.include?('/enc/') }
require 'zlib'
require 'socket'
require 'uri'
require 'openssl'
require 'net/http'
require 'csv'
require 'json'
require 'yaml'
diff = $LOADED_FEATURES - lf

Dir.chdir('../lib')

Dir.mkdir('psdk') unless Dir.exists?('psdk')

loadable_hash = {}
diff.each do |filename|
  if filename.end_with?('.so')
    IO.copy_stream(filename, new_filename = "psdk/#{File.basename(filename)}")
    loadable_hash[new_filename] = nil
  else
    script = File.read(filename)
    script.gsub!("require ", "#")
    rempath = $LOAD_PATH.find { |path| filename.start_with?(path) }
    new_filename = filename.sub(rempath, 'ruby_lib')
    loadable_hash[new_filename] = RubyVM::InstructionSequence.compile(script, new_filename, File.dirname(new_filename)).to_binary
  end
end

File.binwrite('psdk/deps', Marshal.dump(loadable_hash))

system("pause")