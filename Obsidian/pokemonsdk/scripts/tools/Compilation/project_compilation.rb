module ProjectCompilation
  ScriptLoader.load_tool('Compilation/project_compilation_utils')
  ScriptLoader.load_tool('Compilation/project_compilation_data_builder')
  ScriptLoader.load_tool('Compilation/project_compilation_graphics_builder')
  VD_SCRIPT = 'Yuki__VD.rb'
  RELEASE_PATH = 'Release'
  GRAPHICS_FILES = {}
  NO_RECURSIVE_PATH = []
  DATA_FILES = {}

  @scripts = []
  @next_scripts = []
  @yuki_vd = 0

  module_function

  def start
    make_release_path
    start_script_compilation
    make_game_rb
    make_graphic_resources unless ARGV.include?('skip_graphics')
    make_data unless ARGV.include?('skip_data')
    copy_lib unless ARGV.include?('skip_lib')
    copy_audio unless ARGV.include?('skip_audio')
    copy_binaries unless ARGV.include?('skip_binary')
    # copy_plugins
  end

  def start_script_compilation
    compile_rmxp_scripts
    # Compile script from PSDK
    compile_psdk_scripts
    # Compile script from project
    compile_vscode_scripts(ScriptLoader::PROJECT_SCRIPT_PATH)
    save_scripts
  end

  def compile_rmxp_scripts
    ban1 = 'config'
    ban2 = 'boot'
    ban3 = '_'
    load_data('Data/Scripts.rxdata').each do |script|
      # @type [String]
      name = script[1].force_encoding(Encoding::UTF_8)
      next if name.downcase.start_with?(ban1, ban2, ban3)
      @next_scripts << Utils.compile(name, Zlib::Inflate.inflate(script[2]).force_encoding(Encoding::UTF_8))
    end
    GC.start
  end

  def compile_psdk_scripts
    puts 'Compiling PSDK scripts...'
    lines = File.readlines(ScriptLoader::SCRIPT_INDEX_PATH)
    lines.each do |filename|
      filename = filename.chomp
      puts "Compiling #{filename}"
      script = File.read(filename)
      if filename.end_with?(VD_SCRIPT)
        @scripts.insert(@yuki_vd, Utils.compile(filename, script))
        @yuki_vd += 1
      else
        @scripts << Utils.compile(filename, script)
      end
    end
  end

  def compile_vscode_scripts(path)
    compile_scripts(path)
    Dir[File.join(path, '*/')].grep(ScriptLoader::SCRIPT_FOLDER_REG).sort.each do |pathname|
      compile_scripts(pathname)
    end
  end

  def compile_scripts(path)
    Dir[File.join(path, '*.rb')].sort.each do |filename|
      next unless File.basename(filename) =~ /^[0-9]{5}[ _].*/
      puts "Compiling #{filename}"
      script = File.read(filename)
      if filename.end_with?(VD_SCRIPT)
        @scripts.insert(@yuki_vd, Utils.compile(filename, script))
        @yuki_vd += 1
      else
        @scripts << Utils.compile(filename, script)
      end
    end
  end

  def save_scripts
    File.binwrite(File.join(RELEASE_PATH, 'Data', 'Scripts.dat'), Zlib::Deflate.deflate(Marshal.dump(@scripts + @next_scripts)))
    puts 'Script saved...'
  end

  def make_game_rb
    # Compile real Game.rb
    game_script = %w[
      PARGV.rb
      GameLoader/0_fix_update.rb
      GameLoader/1_setupConstantAndLoadPath.rb
      GameLoader/2_displayException.rb
      GameLoader/3_load_extensions.rb
      GameLoader/41_load_data_compiled.rb
      GameLoader/Z_main.rb
      GameLoader/51_load_game_compiled.rb
    ].collect { |filename| File.read("pokemonsdk/scripts/tools/#{filename}") }.join("\r\n\r\n")
    File.binwrite(File.join(RELEASE_PATH, 'Game.yarb'), Utils.compile('Game/Boot.rb', game_script))
    # Write Game.rb
    File.write(File.join(RELEASE_PATH, 'Game.rb'), <<~SCRIPT )
      RubyVM::InstructionSequence.load_from_binary(File.binread('Game.yarb')).eval
      begin
        $GAME_LOOP.call
      rescue Exception
        display_game_exception('An error occured during Game Loop.')
      end
    SCRIPT
  end

  def make_graphic_resources
    release_path = File.join(RELEASE_PATH, 'pokemonsdk', 'master')
    psdk_path = File.join(PSDK_PATH, 'master')
    GRAPHICS_FILES.each do |cache_name, path|
      GraphicsBuilder.start("#{psdk_path}/#{cache_name}", "#{release_path}/#{cache_name}", path, NO_RECURSIVE_PATH.include?(cache_name))
    end
    # Copy Shaders
    Dir['graphics/shaders/*.txt'].each { |filename| File.copy_stream(filename, File.join(RELEASE_PATH, filename)) }
    # Copy Fonts
    Dir['Fonts/*.*'].each { |filename| File.copy_stream(filename, File.join(RELEASE_PATH, filename)) }
  end

  def make_data
    DataBuilder.start(RELEASE_PATH)
  end

  def make_release_path
    Dir.mkdir!(File.join(RELEASE_PATH, 'Data'))
    Dir.mkdir!(File.join(RELEASE_PATH, 'audio', 'bgm'))
    Dir.mkdir!(File.join(RELEASE_PATH, 'audio', 'bgs'))
    Dir.mkdir!(File.join(RELEASE_PATH, 'audio', 'se', 'cries'))
    Dir.mkdir!(File.join(RELEASE_PATH, 'audio', 'se', 'voltorbflip')) if Dir.exist?('audio/se/voltorbflip')
    Dir.mkdir!(File.join(RELEASE_PATH, 'audio', 'me'))
    Dir.mkdir!(File.join(RELEASE_PATH, 'audio', 'particles'))
    Dir.mkdir!(File.join(RELEASE_PATH, 'graphics', 'shaders'))
    Dir.mkdir!(File.join(RELEASE_PATH, 'pokemonsdk', 'master'))
    File.copy_stream('pokemonsdk/version.txt', File.join(RELEASE_PATH, 'pokemonsdk/version.txt'))
    Dir.mkdir!(File.join(RELEASE_PATH, 'Fonts'))
    Dir.mkdir!(File.join(RELEASE_PATH, 'Saves'))
    # Dir.mkdir!(File.join(RELEASE_PATH, 'plugins'))
    Dir.mkdir!(File.join(RELEASE_PATH, 'ruby_builtin_dlls'))
    lib_dirs = Utils.lib_files_to_copy.collect { |filename| File.dirname(filename) }.uniq
    lib_dirs.each do |dirname|
      Dir.mkdir!(File.join(RELEASE_PATH, dirname))
    end
  end

  def copy_lib
    puts 'Copying Ruby Library (add skip_lib to arguments to skip this part)'
    Utils.lib_files_to_copy.each do |filename|
      IO.copy_stream(filename, File.join(RELEASE_PATH, filename))
    end
  end

  def copy_audio
    puts 'Copying Audios (add skip_audio to argument to skip this part)'
    Dir['audio/**/*'].each do |filename|
      next if File.directory?(filename)
      IO.copy_stream(filename, File.join(RELEASE_PATH, filename).downcase)
    end
  end

  def copy_binaries
    puts 'Copying binaries'
    Dir['ruby_builtin_dlls/**'].each do |filename|
      next if File.directory?(filename)
      IO.copy_stream(filename, File.join(RELEASE_PATH, filename))
    end
    %w[
      fmod.dll
      Game.exe
      Game-noconsole.exe
      msvcrt-ruby250.dll
    ].each { |filename| IO.copy_stream(filename, File.join(RELEASE_PATH, filename)) }
  end

  def copy_plugins
    puts 'Copying plugins'
    %w[
      plugins/LiteIGD.rb
    ].each { |filename| IO.copy_stream(filename, File.join(RELEASE_PATH, filename)) }
  end

  def add_graphics_folder(vd_filename, path_from_graphics, recursive = true)
    vd_filename = vd_filename.to_s.downcase
    # Add vd_filename => graphics folder association
    GRAPHICS_FILES[vd_filename] = "graphics/#{path_from_graphics}".downcase
    # Tell if the path is recursive or not (we include the subfolder or not)
    if recursive
      NO_RECURSIVE_PATH.delete(vd_filename)
    else
      NO_RECURSIVE_PATH << vd_filename
    end
  end

  add_graphics_folder('animation', 'animations')
  add_graphics_folder('autotile', 'autotiles')
  add_graphics_folder('ball', 'ball')
  add_graphics_folder('battleback', 'battlebacks')
  add_graphics_folder('battler', 'battlers')
  add_graphics_folder('character', 'characters')
  add_graphics_folder('fog', 'fogs')
  add_graphics_folder('icon', 'icons')
  add_graphics_folder('interface', 'interface')
  add_graphics_folder('panorama', 'panoramas')
  add_graphics_folder('particle', 'particles')
  add_graphics_folder('pc', 'pc')
  add_graphics_folder('picture', 'pictures')
  add_graphics_folder('pokedex', 'pokedex', false)
  add_graphics_folder('title', 'titles')
  add_graphics_folder('tileset', 'tilesets')
  add_graphics_folder('transition', 'transitions')
  add_graphics_folder('windowskin', 'windowskins')
  add_graphics_folder('foot_print', 'pokedex/footprints')
  add_graphics_folder('b_icon', 'pokedex/pokeicon')
  add_graphics_folder('poke_front', 'pokedex/pokefront')
  add_graphics_folder('poke_front_s', 'pokedex/pokefrontshiny')
  add_graphics_folder('poke_back', 'pokedex/pokeback')
  add_graphics_folder('poke_back_s', 'pokedex/pokebackshiny')

  def delete_graphics_folder(vd_filename)
    vd_filename = vd_filename.to_s.downcase
    GRAPHICS_FILES.delete(vd_filename)
    NO_RECURSIVE_PATH.delete(vd_filename)
  end

  def add_data_files(id, &file_list_getter)
    DATA_FILES[id] = file_list_getter
  end

  add_data_files(0) { get_data_files.last }
  add_data_files(1) { get_data_files.first }
  add_data_files(2) { Dir['Data/Text/Dialogs/*.dat'] }
  add_data_files(3) { Dir['Data/PSDK/*.rxdata'] }
  add_data_files(4) { Dir['Data/Animations/*.dat'] }

  def delete_data_files(id)
    DATA_FILES.delete(id)
  end
end

rgss_main {}

ProjectCompilation.start
