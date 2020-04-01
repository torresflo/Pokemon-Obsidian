module ProjectCompilation
  # All the utility function for the project compilation
  module Utils
    module_function

    # Function that permanantely remove a folder and its content
    # @param path [String] path to the folder
    def remove_folder(path)
      system("rm -rf \"#{path}\"") || system("rd /s /q \"#{path}\"")
    end

    # Function that compile a ruby script (and give it a tag according to its location)
    # @param filename [String] name of the file
    # @param script [String] script contents
    # @return [String] compiled script
    def compile(filename, script)
      case File.dirname(filename).split('/').first.downcase
      when '.'
        tag = 'RMXP'
      when 'pokemonsdk'
        tag = 'PSDK'
      when 'scripts'
        tag = 'USER'
      else
        tag = 'UNKNOWN'
      end
      script_filename = "#{tag}/#{filename.sub(%r{(pokemonsdk/scripts|scripts)}i, '')}"
      return RubyVM::InstructionSequence.compile(script, script_filename, '.').to_binary
    end

    # Function that gives all the files from the Ruby lib to copy in Release folder
    # @return [Array<String>]
    def lib_files_to_copy
      lib_path = File.expand_path('lib')
      curr_path = File.expand_path('.') + '/'
      features_in_lib = $LOADED_FEATURES.select { |filename| filename.start_with?(lib_path) }
      utf16 = "#{lib_path}/ruby/2.5.0/i386-mingw32/enc/utf_16le.so"
      features_in_lib << utf16 unless features_in_lib.include?(utf16)
      utf16 = "#{lib_path}/ruby/2.5.0/i386-mingw32/enc/utf_16be.so"
      features_in_lib << utf16 unless features_in_lib.include?(utf16)
      bin = "#{lib_path}/ruby/2.5.0/i386-mingw32/enc/trans/single_byte.so"
      features_in_lib << bin unless features_in_lib.include?(bin)
      pem = "#{lib_path}/cert.pem"
      features_in_lib << pem unless features_in_lib.include?(pem)
      return features_in_lib.collect { |filename| filename.sub(curr_path, '') }
    end
  end
end
