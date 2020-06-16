module ScriptLoader
  # Path of the scripts of PSDK
  VSCODE_SCRIPT_PATH = __FILE__.force_encoding(Encoding::UTF_8).tr('\\', '/').sub(%r{/[^/]+\.rb$}, '').sub(File.expand_path('.') + '/', '')
  # Path of the scripts of the Project
  PROJECT_SCRIPT_PATH = 'scripts'
  # Path to the script index
  SCRIPT_INDEX_PATH = File.join(VSCODE_SCRIPT_PATH, 'script_index.txt')
  # Path to the deflate scripts
  DEFLATE_SCRIPT_PATH = File.join(VSCODE_SCRIPT_PATH, 'mega_script.deflate')
  # Regular expression for script folder
  SCRIPT_FOLDER_REG = %r{/[0-9]+[ _][^/]+/$}i

  module_function

  # Start the script loading sequence
  def start
    unpack_scripts if File.exist?(DEFLATE_SCRIPT_PATH)
    # Load PSDK Scripts
    if File.exist?(index_filename)
      load_script_from_index
    else
      File.open(SCRIPT_INDEX_PATH, 'w') do |file|
        load_vscode_scripts(VSCODE_SCRIPT_PATH, file)
      end
    end
    # Load RMXP Scripts
    load_rmxp_scripts
    # Load Project Scripts
    load_vscode_scripts(PROJECT_SCRIPT_PATH) if index_filename == SCRIPT_INDEX_PATH
  end

  # Load all VSCODE like script from a path and its first level sub paths
  # @param path [String]
  # @param file [File, nil] file used to store the script name
  def load_vscode_scripts(path, file = nil)
    puts format('Loading %<path>s...', path: path)
    load_scripts(path, file)
    Dir[File.join(path, '*/')].grep(SCRIPT_FOLDER_REG).sort.each { |pathname| load_vscode_scripts(pathname, file) }
  end

  # Load all scripts from a path
  # @param path [String]
  # @param file [File, nil] file used to store the script name
  # @note Scripts has to be named "$$$$$ scriptname.rb" where $ are digit
  def load_scripts(path, file = nil)
    Dir[File.join(path, '*.rb')].sort.each do |filename|
      next unless File.basename(filename) =~ /^[0-9]{5}[ _].*/
      file&.puts(filename)
      require(filename)
    end
  rescue StandardError
    if Object.const_defined?(:Yuki) && Yuki.const_defined?(:EXC)
      Yuki::EXC.run($!)
    else
      raise
    end
  end

  # Load the PSDK scripts from the index
  def load_script_from_index
    lines = File.readlines(index_filename)
    path = ENV['ALTERNATIVE_PATH'] || '.'
    lines.each do |filename|
      require(File.join(path, filename.chomp))
    end
  end

  def mkdir(*args)
    curr = args.shift
    Dir.mkdir(curr) unless Dir.exist?(curr)
    args.each do |dirname|
      curr = File.join(curr, dirname)
      Dir.mkdir(curr) unless Dir.exist?(curr)
    end
  end

  # Unpack the scripts
  def unpack_scripts
    hash = Marshal.load(Zlib::Inflate.inflate(File.binread(DEFLATE_SCRIPT_PATH)))
    hash.each do |filename, contents|
      dirname = File.dirname(filename)
      mkdir(*dirname.split('/')) unless Dir.exist?(dirname)
      File.binwrite(filename, contents)
    end
    File.delete(DEFLATE_SCRIPT_PATH)
  end

  # Return the script index filename (taken according to the context)
  # @return [String]
  def index_filename
    return @index_filename if @index_filename
    if !ARGV.grep(/\-\-util[ =]update$/).empty?
      @index_filename = File.join(VSCODE_SCRIPT_PATH, 'script_update_index.txt')
      # Prevent RMXP Scripts from loading
      Kernel.define_method(:eval) { |*args| }
    elsif !(matches = ARGV.grep(/\-\-script_context[ =].+\.txt$/)).empty?
      @index_filename = File.join(VSCODE_SCRIPT_PATH, matches.first.match(/\-\-script_context[ =](.*)/).captures.first)
      # We also don't want custom script in that context
      Kernel.define_method(:eval) { |*args| }
    else
      @index_filename = SCRIPT_INDEX_PATH
    end
    puts "Script Index : #{@index_filename}"
    return @index_filename
  end

  # Load the RMXP scripts
  def load_rmxp_scripts
    ban1 = 'config'
    ban2 = 'boot'
    ban3 = '_'
    load_data('Data/Scripts.rxdata').each do |script|
      # @type [String]
      name = script[1].force_encoding(Encoding::UTF_8)
      next if name.downcase.start_with?(ban1, ban2, ban3)
      eval(Zlib::Inflate.inflate(script[2]).force_encoding(Encoding::UTF_8), $global_binding, name)
      GC.start
    end
  end

  # Load a tool script
  # @param relative_path [String] path from pokemonsdk/scripts/tools to access to the script
  def load_tool(relative_path)
    require "#{VSCODE_SCRIPT_PATH}/tools/#{relative_path}"
  end
end

# Defaulting some old internal PSDK function
module Kernel
  def cc(*)
    0
  end
end
alias pc puts

# Binding allowing to load RMXP Scripts
$global_binding = binding
