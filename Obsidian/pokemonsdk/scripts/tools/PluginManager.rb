# This script allow to manage plugins
#
# To get access to this script write:
#   ScriptLoader.load_tool('PluginManager')
#
# To load the plugins execute:
#   PluginManager.start(:load)
#
# To build a plugin execute:
#   PluginManager.start(:build, 'plugin_name')
#
# To list all the plugins that are installed:
#   PluginManager.start(:list)
class PluginManager
  # Folder containing scripts
  SCRIPTS_FOLDER = 'scripts'
  # Folder containing the plugin scripts
  PLUGIN_SCRIPTS_FOLDER = "#{SCRIPTS_FOLDER}/00000 Plugins"
  # File containing plugin information
  PLUGIN_INFO_FILE = "#{SCRIPTS_FOLDER}/plugins.dat"
  # File extension of plugins
  PLUGIN_FILE_EXT = 'psdkplug'
  # Create a new PluginManager
  # @param type [Symbol] type of management :load, :list or :build
  # @param plugin_name [String] name of the plugin to build (if type == :build)
  def initialize(type, plugin_name = nil)
    @type = type
    @plugin_name = plugin_name
  end

  # Start the plugin manager
  def start
    return build_plugin(@plugin_name) if @type == :build
    return list_plugins if @type == :list

    load_plugins
  end

  private

  # Build a plugin
  # @param name [String] name of the plugin
  def build_plugin(name)
    Builder.new(name).build
  end

  # List all the plugins
  def list_plugins
    @plugins = load_existing_plugins
    show_splash(' List of your plugins')
    @plugins.each do |plugin|
      puts "- \e[1;34m#{plugin.name}\e[1;36m v#{plugin.version}\e[1;37m"
      puts "  authors: #{plugin.authors.join(', ')}"
    end
  end

  # Load all the plugins
  def load_plugins
    @plugin_filenames = Dir[File.join(SCRIPTS_FOLDER, "*.#{PLUGIN_FILE_EXT}")]
    # @type [Array<Config>]
    @old_plugins = load_existing_plugins
    return unless need_to_refresh_plugins?

    show_splash
    cleanup_plugin_scripts
    cleanup_removed_plugins
    @plugins = load_all_plugin_data
    @plugins.each(&:evaluate_pre_compatibility)
    check_dependencies
    @plugins.each_with_index { |plugin, index| plugin.extract(index) }
    ScriptLoader.load_vscode_scripts(PLUGIN_SCRIPTS_FOLDER)
    @plugins.each(&:evaluate_post_compatibility)
    save_data(@plugins.map(&:config), PLUGIN_INFO_FILE)
  end

  # Load the plugins that are already installed
  # @return [Array<Config>]
  def load_existing_plugins
    return File.exist?(PLUGIN_INFO_FILE) ? load_data(PLUGIN_INFO_FILE) : []
  end

  # Show the plugin manager splash
  # @param reason [String] reason to show the splash
  def show_splash(reason = ' Something changed in your plugins! ')
    pcc (sep = ''.center(80, '=')), 0x02
    pcc "##{' PSDK Plugin Manager v1.0 '.center(78, ' ')}#", 0x02
    pcc "##{reason.ljust(78, ' ')}#", 0x02
    pcc sep, 0x02
  end

  # Tell if the plugin manager needs to refresh the plugins
  # @return [Boolean]
  def need_to_refresh_plugins?
    return true if @plugin_filenames.size != @old_plugins.size
    return true if @old_plugins.any? { |plugin| plugin.psdk_version != PSDK_Version }
    return true if @old_plugins.any? { |plugin| !@plugin_filenames.include?(PluginManager.filename(plugin)) }
    return true if PARGV[:util].include?('plugin')

    return false
  end

  # Function that cleans the plugin scripts up
  def cleanup_plugin_scripts
    glob = File.join(PLUGIN_SCRIPTS_FOLDER, '**', '*')
    Dir[glob].select { |f| File.file?(f) }.sort_by { |f| -f.size }.each { |f| File.delete(f) }
    Dir[glob].sort_by { |f| -f.size }.each { |f| Dir.delete(f) }
  end

  # Function that cleanup the removed plugins
  def cleanup_removed_plugins
    removed_plugins = @old_plugins.reject { |plugin| @plugin_filenames.include?(PluginManager.filename(plugin)) }
    removed_plugins.each { |plugin| cleanup_plugin(plugin) }
  end

  # Function that clean a plugin up
  # @param plugin [Config]
  def cleanup_plugin(plugin)
    return if plugin.added_files.empty?

    files_to_remove = plugin.added_files.flat_map { |dirglob| Dir[dirglob] }.sort_by { |f| -f.size }
    return if files_to_remove.empty?

    print "The plugin \"#{plugin.name}\" has been removed, it added #{files_to_remove.size}.\nDo you want to remove the files? [Y/N]: "
    ans = STDIN.gets.chomp
    return unless ans.downcase == 'y'

    files_to_remove.each { |filename| File.delete(filename) }
  end

  # Function that load all the plugin data
  # @return [Array<LoadedPlugin>]
  def load_all_plugin_data
    return @plugin_filenames.map { |filename| LoadedPlugin.new(filename) }
  end

  # Function that checks (and download) dependencies of all plugins
  def check_dependencies
    to_download = @plugins.flat_map { |plugin| plugin.dependencies_to_download(@plugins) }
    to_download.uniq(&:name).each(&:download)
    unless to_download.empty?
      @plugin_filenames = Dir[File.join(SCRIPTS_FOLDER, "*.#{PLUGIN_FILE_EXT}")]
      @plugins = load_all_plugin_data
    end
    incompatible_plugins = all_incompatible_plugin_message
    if incompatible_plugins.any?
      pcc 'There\'s plugin incompatibilities!', 0x01
      pcc incompatible_plugins, 0x01
      raise 'Incompatible plugin detected'
    end
    order_dependencies
  end

  # Function that orders the plugins by dependencies
  def order_dependencies
    @plugins.each { |plugin| plugin.build_dependency_list(@plugins) }
    assign_dependency_level_to_plugins
    @plugins.sort! do |a, b|
      next 1 if a.dependencies.include?(b)
      next -1 if b.dependencies.include?(a)

      res = a.dependency_level <=> b.dependency_level
      next res if res != 0

      next a.config.name <=> b.config.name # Ensure that plugin on same level are always on same order
    end
  end

  # Function that assign the correct dependency level to the plugins
  def assign_dependency_level_to_plugins
    @plugins.each { |plugin| plugin.dependency_level = 0 if plugin.dependencies.empty? }
    level = 0
    plugins_to_assign = @plugins.reject(&:dependency_level)
    while plugins_to_assign.any? { |plugin| !plugin.dependency_level }
      plugins_to_assign.each do |plugin|
        next unless plugin.dependencies.all? { |dependency| dependency.dependency_level && dependency.dependency_level <= level }

        plugin.dependency_level ||= level + 1
      end
      level += 1
      plugins_to_assign = plugins_to_assign.reject(&:dependency_level)
    end
  end

  # List all the message for incompatible plugin
  # @return [Array<String>]
  def all_incompatible_plugin_message
    return @plugins.flat_map { |plugin| plugin.all_incompatible_plugin_message(@plugins) }
  end

  class << self
    # Function that starts the plugin manager
    # @param type [Symbol] type of management :load or :build
    # @param plugin_name [String] name of the plugin to build (if type == :build)
    def start(type, plugin_name = nil)
      new(type, plugin_name).start
    end

    # Get the plugin filename from a config
    # @param plugin [Config]
    def filename(plugin)
      File.join(SCRIPTS_FOLDER, "#{plugin.name}.#{PLUGIN_FILE_EXT}")
    end
  end

  # Plugin configuration
  class Config
    # Get the plugin name
    # @return [String]
    attr_accessor :name
    # Get the plugin authors
    # @return [Array<String>]
    attr_accessor :authors
    # Get the version of the plugin
    # @return [String]
    attr_accessor :version
    # Get the dependecies or incompatibilities of the plugin
    # @return [Array<Hash>]
    attr_accessor :deps
    # Get the script that tests if PSDK is compatible with this plugin
    # @return [String, nil]
    attr_accessor :psdk_compatibility_script
    # Tell if the psdk_compatibility_script should be executed after all plugins has been loaded
    # @return [Boolean, nil]
    attr_accessor :retry_psdk_compatibility_after_plugin_load
    # Get the script that tests if the plugin is compatible with other plugins
    # @return [String, nil]
    attr_accessor :additional_compatibility_script
    # Get all the files added by the plugin (in order to compile the plugin / remove files)
    # @return [Array<String>]
    attr_accessor :added_files
    # Get the SHA512 of the plugin (computed after it got compiled)
    # @return [String]
    attr_accessor :sha512
    # Get the PSDK version the plugin was installed
    # @return [Integer]
    attr_accessor :psdk_version
  end

  # Class describing a loaded plugin (in order to process it)
  class LoadedPlugin
    # Message for incompatible plugins
    INCOMPATIBLE_MESSAGE = '%s is incompatible with %s from v%s to v%s'
    # Message shown when a dependency plugin has a bad version
    INCOMPATIBLE_VERSION_MESSAGE = '%s depends on plugin %s between v%s & v%s, got v%s'
    # Get the plugin configuration
    # @return [Config]
    attr_reader :config
    # Get the dependency list if built
    # @return [Array<LoadedPlugin>]
    attr_reader :dependencies
    # Get/Set the dependency level (for sorting)
    # @return [Integer]
    attr_accessor :dependency_level

    # Create a new loaded plugin
    # @param filename [String]
    def initialize(filename)
      @yuki_vd = Yuki::VD.new(filename, :read)
      @config_data = @yuki_vd.read_data("\x00")
      # @type [Config]
      @config = Marshal.load(@config_data)
      @config.psdk_version = PSDK_Version
      validate_file
    end

    # List the dependencies that needs to be downloaded
    # @param plugins [Array<LoadedPlugin>]
    # @return [Array<PluginToDownload>]
    def dependencies_to_download(plugins)
      hashes = @config.deps.reject { |hash| hash[:incompatible] || plugins.any? { |plugin| plugin.config.name == hash[:name] } }
      return hashes.map { |hash| PluginToDownload.new(hash[:name], hash[:url]) }
    end

    # List all the incompatible plugins message
    # @param plugins [Array<LoadedPlugin>]
    # @return [Array<String>]
    def all_incompatible_plugin_message(plugins)
      incompatible = @config.deps.select do |hash|
        next false unless hash[:incompatible]
        next false unless (ic = plugins.find { |plugin| plugin.config.name == hash[:name] })
        next false unless ic.version_match?(hash[:version_min], hash[:version_max])

        next true
      end
      return incompatible.map do |hash|
        format(INCOMPATIBLE_MESSAGE, @config.name, hash[:name], hash[:version_min] || '0.0.0.0', hash[:version_max] || 'Infinity')
      end
    end

    # Tell if the version match
    # @param min [String, nil]
    # @param max [String, nil]
    # @return [Boolean]
    def version_match?(min, max)
      return false if min && @config.version < min
      return false if max && @config.version > max

      return true
    end

    # Build the dependency list
    # @param plugins [Array<LoadedPlugin>]
    def build_dependency_list(plugins)
      direct_dependency = dependency_from_deps(@config.deps, plugins)
      cyclic_dep = direct_dependency.find { |plugin| dependency_of?(plugin) }
      raise "Cyclic dependency detected between #{@config.name} & #{cyclic_dep.config.name}" if cyclic_dep

      version_error_message = check_direct_dependency_version(direct_dependency)
      if version_error_message.any?
        pcc 'There\'s plugin with bad version!', 0x01
        pcc version_error_message, 0x01
        raise 'Incompatible plugin detected'
      end

      direct_dependency.concat(direct_dependency.flat_map { |plugin| recursive_dependency(plugin, plugins) })
      @dependencies = direct_dependency.uniq
    end

    # Test if a plugin directly depends on this plugin
    # @param plugin [LoadedPlugin]
    # @return [Boolean]
    def dependency_of?(plugin)
      plugin.config.deps.any? { |hash| hash[:name] == @config.name }
    end

    # Extract the plugin
    # @param index [Integer] index of the plugin in the plugin list
    def extract(index)
      scripts, output_scripts, others, dirnames = list_filename_and_dirnames(index)
      dirnames.each { |dirname| Dir.mkdir!(dirname) unless Dir.exist?(dirname) }

      puts "Extracting scripts for #{@config.name} plugin..." if output_scripts.any?
      output_scripts.each_with_index do |script_filename, i|
        File.write(script_filename, @yuki_vd.read_data(scripts[i]).force_encoding(Encoding::UTF_8))
      end

      puts "Extracting resources of #{@config.name} plugin..." if others.any?
      others.each do |filename|
        if File.exist?(filename)
          puts "Skipping #{filename} (exist)"
          next
        end

        File.binwrite(filename, @yuki_vd.read_data(filename))
      end
    end

    # Test if the plugin is compatible with PSDK
    def evaluate_pre_compatibility
      return unless (script_to_evaluate = @yuki_vd.read_data("\x01"))

      eval(script_to_evaluate, TOPLEVEL_BINDING)
    rescue Exception
      pcc "#{@config.name} could not validate compatibility with PSDK", 0x01
      pcc "Reason: #{$!.message}", 0x01
      raise 'Incompatible plugin detected'
    end

    # Test if the plugin is compatible with other plugins
    def evaluate_post_compatibility
      if @config.retry_psdk_compatibility_after_plugin_load && (script_to_evaluate = @yuki_vd.read_data("\x01"))
        eval(script_to_evaluate, TOPLEVEL_BINDING)
      end
      return unless (script_to_evaluate = @yuki_vd.read_data("\x02"))

      eval(script_to_evaluate, TOPLEVEL_BINDING)
    rescue Exception
      pcc "#{@config.name} could not validate compatibility with other plugins", 0x01
      pcc "Reason: #{$!.message}", 0x01
      raise 'Incompatible plugin detected'
    end

    private

    # Create the filename & dirname lists
    # @param index [Integer] index of the plugin in the plugin list
    # @return [Array<Array<String>>]
    def list_filename_and_dirnames(index)
      filenames = @yuki_vd.get_filenames.select { |filename| filename.include?('/') }
      scripts_folder = "#{SCRIPTS_FOLDER}/"
      scripts = filenames.select { |filename| filename.start_with?(scripts_folder) }
      others = filenames.reject { |filename| filename.start_with?(scripts_folder) }
      plugin_script_folder = format('%<folder>s/%05<index>d %<name>s/', folder: PLUGIN_SCRIPTS_FOLDER, index: index, name: @config.name)
      output_scripts = scripts.map { |filename| filename.sub(scripts_folder, plugin_script_folder) }

      dirnames = output_scripts.map { |filename| File.dirname(filename) }.uniq
      dirnames.concat(others.map { |filename| File.dirname(filename) }.uniq)
      return scripts, output_scripts, others, dirnames
    end

    # Check if all direct dependencies match the version, if not add message in output about it
    # @param direct_dependency [Array<LoadedPlugin>]
    # @return [Array<String>]
    def check_direct_dependency_version(direct_dependency)
      bad_deps = @config.deps.reject { |hash| hash[:incompatible] }.select do |hash|
        next true unless (dependency = direct_dependency.find { |plugin| plugin.config.name == hash[:name] })
        next true unless dependency.version_match?(hash[:version_min], hash[:version_max])

        next false
      end

      return bad_deps.map do |hash|
        dependency_version = direct_dependency.find { |plugin| plugin.config.name == hash[:name] }&.config&.version || 'NotFound'
        next format(INCOMPATIBLE_VERSION_MESSAGE, @config.name,
                    hash[:name], hash[:version_min] || '0.0.0.0', hash[:version_max] || 'Infinity', dependency_version)
      end
    end

    # Get the recursive dependency of the plugin
    # @param plugin [LoadedPlugin]
    # @param plugins [Array<LoadedPlugin>]
    # @return [Array<LoadedPlugin>]
    def recursive_dependency(plugin, plugins)
      next_dependencies = dependency_from_deps(plugin.config.deps, plugins)
      return [] if next_dependencies.empty?

      cyclic_dep = next_dependencies.find { |sub_plugin| dependency_of?(sub_plugin) }
      raise "Cyclic dependency detected between #{@config.name} & #{cyclic_dep.config.name}" if cyclic_dep

      next_dependencies.concat(next_dependencies.flat_map { |sub_plugin| recursive_dependency(sub_plugin, plugins) })
      return next_dependencies
    end

    # Get dependency from deps
    # @param deps [Array<Hash>]
    # @param plugins [Array<LoadedPlugin>]
    # @return [Array<LoadedPlugin>]
    def dependency_from_deps(deps, plugins)
      deps = deps.reject { |hash| hash[:incompatible] }
      return plugins.select { |plugin| deps.any? { |hash| hash[:name] == plugin.config.name } }
    end

    # Function that validate the plugin file
    def validate_file
      # @type [IO]
      file = @yuki_vd.instance_variable_get(:@file)
      file.pos = 0
      content_to_read = file.read(Yuki::VD::POINTER_SIZE).unpack1(Yuki::VD::UNPACK_METHOD) - @config_data.bytesize - Yuki::VD::POINTER_SIZE * 2
      sha512 = Digest::SHA512.hexdigest(file.read(content_to_read))
      raise "Plugin #{@config.name} is invalid" if sha512 != @config.sha512
    end

    # Plugin that needs to be downloaded
    class PluginToDownload
      # Name of the plugin
      # @return [String]
      attr_reader :name
      # Url of the plugin
      # @return [String]
      attr_reader :url

      # Create a new plugin to download
      # @param name [String] name of the plugin
      # @param url [String] url of the plugin
      def initialize(name, url)
        @name = name
        @url = url
      end

      # Download the plugin
      def download
        puts "Downloading #{name}..."
        data = Net::HTTP.get(URI(@url))
        File.binwrite(PluginManager.filename(self), data)
        puts 'Done!'
      end
    end
  end

  # Class responsive of building plugins
  class Builder
    # Create a new plugin builder
    # @param name [String] name of the plugin in scripts/
    def initialize(name)
      @name = name
    end

    # Start the building process
    def build
      puts "Building #{@name}..."
      @config = load_plugin_configuration
      @yuki_vd = Yuki::VD.new(plugin_filename = "#{PluginManager.filename(@config)}.tmp", :write)
      add_scripts
      add_files
      add_testers
      @yuki_vd.close
      filesize = File.binread(plugin_filename, Yuki::VD::POINTER_SIZE).unpack1(Yuki::VD::UNPACK_METHOD) - Yuki::VD::POINTER_SIZE
      filedata = File.binread(plugin_filename, filesize, Yuki::VD::POINTER_SIZE)
      @config.sha512 = Digest::SHA512.hexdigest(filedata)
      @yuki_vd = Yuki::VD.new(plugin_filename, :update)
      @yuki_vd.write_data("\x00", Marshal.dump(@config))
      @yuki_vd.close
      File.rename(plugin_filename, plugin_filename.sub('.tmp', ''))
      puts 'Done!'
    end

    private

    # Function that adds all the scripts for the plugin
    def add_scripts
      basedir = "#{SCRIPTS_FOLDER}/#{@name}/"
      scripts = Dir[File.join(basedir, SCRIPTS_FOLDER, '**', '*.rb')]
      scripts.each do |filename|
        script = File.read(filename)
        @yuki_vd.write_data(filename.sub(basedir, ''), script)
      end
    end

    # Function that add all the files for the plugin
    def add_files
      filenames = @config.added_files.flat_map { |dirspec| Dir[dirspec] }
      filenames.each do |filename|
        data = File.binread(filename)
        @yuki_vd.write_data(filename, data)
      end
    end

    # Function that adds the compatibility test script
    def add_testers
      if @config.psdk_compatibility_script
        data = File.read(File.join(SCRIPTS_FOLDER, @name, @config.psdk_compatibility_script))
        @yuki_vd.write_data("\x01", data)
      end
      if @config.additional_compatibility_script
        data = File.read(File.join(SCRIPTS_FOLDER, @name, @config.additional_compatibility_script))
        @yuki_vd.write_data("\x02", data)
      end
    end

    # Load the plugin configuration
    # @return [Config]
    def load_plugin_configuration
      YAML.load(File.read(File.join(SCRIPTS_FOLDER, @name, 'config.yml')))
    end
  end
end
