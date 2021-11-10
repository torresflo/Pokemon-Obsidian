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
      ld_feature = $LOADED_FEATURES.map { |filename| filename.dup.force_encoding(Encoding::UTF_8) }
      features_in_lib = ld_feature.select { |filename| filename.start_with?(lib_path) }
      Dir["#{lib_path}/ruby/3.0.0/i386-mingw32/enc/*.so"].each do |so|
        features_in_lib << so unless features_in_lib.include?(so)
      end
      Dir["#{lib_path}/ruby/3.0.0/i386-mingw32/enc/trans/*.so"].each do |so|
        features_in_lib << so unless features_in_lib.include?(so)
      end
      Dir["#{lib_path}/ruby/gems/3.0.0/specifications/*.gemspec"].each do |gem|
        features_in_lib << gem unless features_in_lib.include?(gem)
      end
      Dir["#{lib_path}/ruby/gems/3.0.0/specifications/default/*.gemspec"].each do |gem|
        features_in_lib << gem unless features_in_lib.include?(gem)
      end
      pem = "#{lib_path}/cert.pem"
      features_in_lib << pem unless features_in_lib.include?(pem)
      return features_in_lib.collect { |filename| filename.sub(curr_path, '') }
    end

    # Function that tests if the script is a bootloader
    # @param script [String]
    # @return [Boolean]
    def script_bootloader?(script)
      return script.start_with?('# ProjectCompilation: BootLoader')
    end

    # Function that process a bootloader script
    # @param script [String]
    # @param scripts [Array]
    # @param dirname [String] relative directory of the bootloader script (to match require_relative)
    def process_bootloader(script, scripts, dirname)
      # @type [Array<String>]
      lines = script.split("\n").map(&:strip)
      return unless bootloader_condition_valid?(lines)

      scripts_to_load_lines = lines.select { |line| line.start_with?("require_relative '") && line.end_with?("'") && !line.include?('.rb') }
      scripts_to_load_lines.each do |line|
        script_name = line.sub("require_relative '", '').sub("'", '.rb')
        filename = File.join(dirname, script_name)
        puts "Compiling #{filename}"
        scripts << compile(filename, File.read(filename))
      end
    end

    # Function that tests if the condition is valid
    # @param lines [Array<String>]
    def bootloader_condition_valid?(lines)
      condition = lines.find { |line| line.start_with?('# ProjectCompilationCondition:') }
      return true unless condition

      return eval(condition.sub('# ProjectCompilationCondition:', ''), TOPLEVEL_BINDING)
    rescue
      puts 'Failed to validate condition'
      puts $!
      return false
    end
  end
end
