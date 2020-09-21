require 'yaml'

# Project structure :
# A project is stored inside {project_path}/project.yml.
#
# The project contains the following data
# * maps : A hash of tmx filename to Hash info (id: Integer, tileset: String)
# * tilesets : A hash of tileset name (string) to png filename
class TMXConverter
  # Path to the data used by the converter
  DATA_PATH = '.tmxconverter'
  # Name of the default project file
  DEFAULT_PROJECT_FILENAME = 'default_project.txt'
  # Name of the project info file
  PROJECT_INFO_FILENAME = 'project.yml'

  # Function that loads the project
  def load_project
    if ARGV.empty?
      @project_path = retreive_project_path
    else
      @project_path = ARGV.first
    end
    Dir.chdir(@project_path)
    Dir.mkdir(DATA_PATH) unless Dir.exist?(DATA_PATH)
    load_project_data
  end

  # Function that return the project patch
  # @return [String]
  def retreive_project_path
    default_project = retreive_default_project
    current_choice = ''
    message = format('Enter the tiled project path %<default>s: ', default: default_project.empty? ? '' : "[#{default_project}]")
    until Dir.exist?(current_choice)
      current_choice = user_input(message)
                       .gsub(/"([^"]*)"/) { Regexp.last_match(1) }
                       .tr(92.chr, '/')
      current_choice = default_project if current_choice.empty?
    end
    File.write(DEFAULT_PROJECT_FILENAME, current_choice) unless File.exist?(DEFAULT_PROJECT_FILENAME)
    return current_choice
  end

  # Function that gets the default project
  # @return [String]
  def retreive_default_project
    if File.exist?(DEFAULT_PROJECT_FILENAME)
      return File.read(DEFAULT_PROJECT_FILENAME).tr(92.chr, '/')
    end
    return ''
  end

  # Function that loads project data
  def load_project_data
    if File.exist?(PROJECT_INFO_FILENAME)
      @project_data = YAML.load_file(PROJECT_INFO_FILENAME)
      raise LoadError, 'Corrupted project data' unless @project_data.is_a?(Hash)
    else
      @project_data = {}
    end
    ajust_project_data
    load_project_tilesets
  end

  # Function that adjust project data
  def ajust_project_data
    project_data = @project_data
    project_data[:maps] = {} unless project_data[:maps].is_a?(Hash)
    project_data[:tilesets] = {} unless project_data[:tilesets]
  end

  # Function that save the project data
  def save_project
    File.open(PROJECT_INFO_FILENAME, 'w') do |file|
      YAML.dump(@project_data, file)
    end
    Dir.chdir(DATA_PATH) do
      @project_tilesets.each do |name, data|
        tileset_filename = format('tileset_%<key>s', key: name)
        save_data(data, tileset_filename)
      end
    end
  end

  # Function that loads all the project tilesets
  def load_project_tilesets
    @project_tilesets = {}
    Dir.chdir(DATA_PATH) do
      @project_data[:tilesets].each_key do |key|
        tileset_filename = format('tileset_%<key>s', key: key)
        if File.exist?(tileset_filename)
          @project_tilesets[key] = load_data(tileset_filename)
        else
          puts format('Tileset %<key>s not found, creating a new one', key: key)
          @project_tilesets[key] = TMX_Tileset.new(key)
        end
      end
    end
  end
end
