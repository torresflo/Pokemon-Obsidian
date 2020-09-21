require 'yaml'

# Project structure :
# A project is stored inside {project_path}/project.yml.
#
# The project contains the following data
# * maps : A hash of tmx filename to Hash info (id: Integer, tileset: String)
# * tilesets : A hash of tileset name (string) to png filename
class TMXConverter
  # Name of the default output file
  DEFAULT_OUTPUT_FILENAME = 'default_output.txt'

  # Function that defines the output
  def setup_output
    if ARGV.empty?
      @output_dir = retreive_output_path
    else
      @output_dir = ARGV.first
    end
  end

  # Function that return the output path
  # @return [String]
  def retreive_output_path
    default_output = retreive_default_output_path
    current_choice = ''
    message = format('Enter the output path %<default>s: ', default: default_output.empty? ? '' : "[#{default_output}]")
    until Dir.exist?(current_choice)
      current_choice = user_input(message)
                       .gsub(/"([^"]*)"/) { Regexp.last_match(1) }
                       .tr(92.chr, '/')
      current_choice = default_output if current_choice.empty?
    end
    File.write(DEFAULT_OUTPUT_FILENAME, current_choice) unless File.exist?(DEFAULT_OUTPUT_FILENAME)
    return current_choice
  end

  # Function that gets the default project
  # @return [String]
  def retreive_default_output_path
    if File.exist?(DEFAULT_OUTPUT_FILENAME)
      return File.read(DEFAULT_OUTPUT_FILENAME).tr(92.chr, '/')
    end
    return ''
  end
end
