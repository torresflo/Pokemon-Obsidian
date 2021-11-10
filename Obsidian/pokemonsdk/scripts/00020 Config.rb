# Module responsive of giving access to various configuration contained into Data/configs
#
# @example How to create a basic configuration
#   module Configs
#     class MyConfigDescription
#       # Define attributes etc...
#       def initialize # <= Configs will call this without argument so you can set default value if file does not exist
#       end
#     end
#     # @!method self.my_config_accessor
#     #   @return [MyConfigDescription]
#     register(:my_config_accessor, 'my_config', :json, false, MyConfigDescription)
#   end
module Configs
  # List of all registered configs
  @all_registered_configs = {}

  class << self
    # Register a new config
    # @param name [Symbol] name of the config
    # @param filename [String] name of the file inside Data/configs
    # @param type [Symbol] type of the config file: :yml or :json
    # @param preload [Boolean] if the file need to be preloaded
    # @param klass [Class] class describing the config content
    def register(name, filename, type, preload, klass)
      @all_registered_configs[name] = { filename: filename, type: type, klass: klass }
      if preload
        load_file_data(name)
      else
        define_singleton_method(name) { load_file_data(name) }
      end
    end

    private

    # Function that loads the file data
    # @param name [Symbol] name of the file data to load
    # @return [Object, nil] whatever was loaded or initialized
    def load_file_data(name)
      return unless (info = @all_registered_configs[name])

      rxdata_filename = format('Data/configs/%<filename>s.rxdata', filename: clean_filename(info[:filename]))
      if PSDK_CONFIG.release?
        data = load_data(rxdata_filename)
        define_singleton_method(name) { data }
        return data
      end

      real_filename = format('Data/configs/%<filename>s.%<ext>s', filename: info[:filename], ext: info[:type])
      dirname = File.dirname(real_filename)
      Dir.mkdir!(dirname) unless Dir.exist?(dirname)
      data = load_config_data(info, rxdata_filename, real_filename)

      define_singleton_method(name) { data }
      return data
    end

    # Function that cleans the filename for rxdata files
    # @param filename [String]
    # @return [String]
    def clean_filename(filename)
      filename.gsub('/', '_')
    end

    # Function that load the config data in non-release mode
    # @param info [Hash]
    # @param rxdata_filename [String]
    # @param real_filename [String]
    def load_config_data(info, rxdata_filename, real_filename)
      if File.exist?(real_filename) && File.exist?(rxdata_filename) && (File.mtime(real_filename) <= File.mtime(rxdata_filename))
        return load_data(rxdata_filename)
      elsif File.exist?(real_filename)
        log_info("Loading config file #{real_filename}")
        file_content = File.read(real_filename)
        data = info[:type] == :yml ? YAML.load(file_content) : JSON.load(file_content)
        if data.is_a?(Hash)
          pre_data = data
          data = info[:klass].new
          pre_data.each do |key, value|
            data.send("#{key}=", value)
          end
        elsif !data.is_a?(info[:klass])
          raise "Invalid klass #{data.class} for file #{real_filename}, expected #{info[:klass]}"
        end
      else
        log_info("Creating config file #{real_filename}")
        data = info[:klass].new
        File.write(real_filename, info[:type] == :yml ? YAML.dump(data) : JSON.dump(data))
      end

      save_data(data, rxdata_filename)
      return data
    end
  end
end
