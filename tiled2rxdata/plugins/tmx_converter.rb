require 'plugins/tmx_converter_tiled_project'
require 'plugins/tmx_converter_help'
require 'plugins/tmx_converter_commands'
require 'plugins/tmx_converter_convert_map'
require 'plugins/tmx_converter_build_tileset'
require 'plugins/tmx_converter_output'
require 'plugins/tmx_tileset'
require 'plugins/rpg_data'

# Class that perform the TMX conversion according to the user inputs
class TMXConverter
  # Create the TMX converter and do the job
  def initialize
    @exe_path = File.expand_path('.')
    setup_output
    load_project
  end

  # Start user interface
  def start
    while (cmd = user_input('> '))
      interpret_command(split_command(cmd))
    end
  end

  # Interpret a user command
  # @param cmd [Array<String>]
  def interpret_command(cmd)
    case cmd.first
    when 'add'
      interpret_add_command(cmd[1..-1])
    when 'reset'
      interpret_reset_command(cmd[1..-1])
    when 'del'
      interpret_del_command(cmd[1..-1])
    when 'convert'
      interpret_convert_command(cmd[1..-1])
    when 'list'
      interpret_list_command(cmd[1..-1])
    when 'build'
      build_tilesets
    when 'run'
      run_converter
    when 'save'
      save_project
    when 'exit'
      exit_converter
    when 'help'
      show_help
    when 'debug'
      debug_converter
    end
  end

  # Function that split a user command to smaller elements
  # @example split_command('test "things with spaces" no_sp') => ["test", "things with spaces", "no_sp"]
  # @param cmd [String]
  # @return [Array<String>]
  def split_command(cmd)
    arr = cmd.split(/("[^"]+"| )/)
    arr.select! { |e| !e.empty? && e != ' ' }
    arr.collect { |e| e.gsub(/"([^"]+)"/) { Regexp.last_match(1) } }
  end

  # Function that exit the converter
  def exit_converter
    define_singleton_method(:user_input) do |*|
      return nil
    end
  end

  # Function that exit the converter
  def run_converter
    interpret_convert_command(['*'])
    build_tilesets
    exit_converter
  end

  # Function that retreive the user input
  # @param prompt [String] the propted message before the input
  # @return [String] the input
  def user_input(prompt = nil)
    print(prompt) if prompt
    return STDIN.gets.chomp
  end
end

# Register the thing to do
$GAME_LOOP = proc {
  TMXConverter.new.start
}
