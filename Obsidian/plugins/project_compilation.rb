module ProjectCompilation
  BOOT_SCRIPT_NAME = 'Scripts.rxdata/Boot (Tu touche ton projet est mort)'
  VD_SCRIPT = 'Yuki__VD.rb'
  RELEASE_PATH = 'Release'
  GRAPHICS_FILES = {
    animation: 'animations',
    autotile: 'autotiles',
    ball: 'ball',
    battleback: 'battlebacks',
    battler: 'battlers',
    character: 'characters',
    fog: 'fogs',
    icon: 'icons',
    interface: 'interface',
    panorama: 'panoramas',
    particle: 'particles',
    pc: 'pc',
    picture: 'pictures',
    pokedex: 'pokedex',
    title: 'titles',
    tileset: 'tilesets',
    transition: 'transitions',
    windowskin: 'windowskins',
    foot_print: 'pokedex/footprints',
    b_icon: 'pokedex/pokeicon',
    poke_front: 'pokedex/pokefront',
    poke_front_s: 'pokedex/pokefrontshiny',
    poke_back: 'pokedex/pokeback',
    poke_back_s: 'pokedex/pokebackshiny'
  }
  GRAPHICS_FILES.each { |key, value| GRAPHICS_FILES[key] = "graphics/#{value}" }
  NO_RECURSIVE_PATH = %i[pokedex]
  
  
  @scripts = []
  @next_scripts = []
  @yuki_vd = 0
  
  module_function
  
  def start
    make_release_path
    start_script_compilation
    make_game_rb
    make_graphic_resources
    make_data
    copy_lib if !ARGV.include?('skip_lib')
    copy_audio if !ARGV.include?('skip_audio')
    copy_binaries
    copy_plugins
  end
  
  def start_script_compilation
    compile_rmxp_scripts
    # Compile script from PSDK
    compile_psdk_scripts #compile_vscode_scripts(ScriptLoader::VSCODE_SCRIPT_PATH)
    # Compile script from project
    compile_vscode_scripts(ScriptLoader::PROJECT_SCRIPT_PATH)
    save_scripts
  end
  
  def compile(filename, script)
    RubyVM::InstructionSequence.compile(script, File.basename(filename), File.dirname(filename)).to_binary
  end
  
  def compile_rmxp_scripts
    do_next_scripts = false
    load_data('Data/Scripts.rxdata').each do |script_arr|
      script = Zlib::Inflate.inflate(script_arr[2]).force_encoding(Encoding::UTF_8)
      next if script.size < 10 # No short script allowed
      name = "Scripts.rxdata/#{script_arr[1].force_encoding(Encoding::UTF_8)}"
      next(do_next_scripts = true) if name == BOOT_SCRIPT_NAME
      puts "Compiling #{name}"
      (do_next_scripts ? @next_scripts : @scripts) << compile(name, script)
    end
  end

  def compile_psdk_scripts
    puts "Compiling PSDK scripts..."
    lines = File.readlines(ScriptLoader::SCRIPT_INDEX_PATH)
    lines.each do |filename|
      filename = filename.chomp
      puts "Compiling #{filename}"
      script = File.read(filename)
      if filename.end_with?(VD_SCRIPT)
        @scripts.insert(@yuki_vd, compile(filename, script))
        @yuki_vd += 1
      else
        @scripts << compile(filename, script)
      end
    end
  end

  def compile_vscode_scripts(path)
    compile_scripts(path)
    Dir[File.join(path, '*/')].sort.each { |pathname| compile_scripts(pathname) }
  end

  def compile_scripts(path)
    Dir[File.join(path, '*.rb')].sort.each do |filename|
      next unless File.basename(filename) =~ /^[0-9]{5} .*/
      puts "Compiling #{filename}"
      script = File.read(filename)
      if filename.end_with?(VD_SCRIPT)
        @scripts.insert(@yuki_vd, compile(filename, script))
        @yuki_vd += 1
      else
        @scripts << compile(filename, script)
      end
    end
  end
  
  def save_scripts
    File.binwrite(File.join(RELEASE_PATH, 'Data', 'Scripts.dat'), Zlib::Deflate.deflate(Marshal.dump(@scripts + @next_scripts)))
    puts "Script saved..."
  end
  
  def make_game_rb
    # Compile real Game.rb
    parse_args = File.read('lib/__parse_argments.rb')
    parse_args.sub!('add(:tags', '# ')
    parse_args.sub!('add(:worldmap', '# ')
    parse_args.sub!('add(:"animation', '# ')
    parse_args.sub!('add(:test', '# ')
    parse_args.sub!('add(:util', '# ')
    game_script = File.read(File.join(PSDK_PATH, '__ReleaseGame.rb'))
    game_script.sub!('{ARGUMENT_PARSE}', parse_args)
    File.binwrite(File.join(RELEASE_PATH, 'Game.yarb'), compile('Game/Boot.rb', game_script))
    # Write Game.rb
    File.write(File.join(RELEASE_PATH, 'Game.rb'), <<-SCRIPT )
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
    Dir.mkdir!(File.join(RELEASE_PATH, 'Fonts'))
    Dir.mkdir!(File.join(RELEASE_PATH, 'Saves'))
    Dir.mkdir!(File.join(RELEASE_PATH, 'plugins'))
    Dir.mkdir!(File.join(RELEASE_PATH, 'ruby_builtin_dlls'))
    Dir['lib/**/'].each do |dirname|
      Dir.mkdir!(File.join(RELEASE_PATH, dirname[0...-1]))
    end
  end

  def copy_lib
    puts "Copying Ruby Library (add skip_lib to arguments to skip this part)"
    Dir['lib/**/*'].each do |filename|
      next if File.directory?(filename)
      IO.copy_stream(filename, File.join(RELEASE_PATH, filename))
    end
  end

  def copy_audio
    puts "Copying Audios (add skip_audio to argument to skip this part)"
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
end

class GraphicsBuilder
  def initialize(origin_vd, target_vd, path, no_recursive)
    puts "Loading #{path}"
    @files = {}
    load_all_original_files(origin_vd)
    load_files_from_path(path, no_recursive)
    puts "Saving #{path}"
    save(target_vd)
  end
  
  def save(target_vd)
    vd = Yuki::VD.new(target_vd, :write)
    @files.each do |filename, data|
      vd.write_data(filename, data)
    end
    vd.close
    vd = nil
    @files = nil
    GC.start
  end
  
  def load_all_original_files(origin_vd)
    vd = Yuki::VD.new(origin_vd, :read)
    vd.get_filenames.each do |filename|
      @files[filename.downcase] = vd.read_data(filename)
    end
    vd.close
    vd = nil
  end
  
  def load_files_from_path(path, no_recursive)
    load_all_from_path(path, path)
    return if no_recursive
    load_recursive_from_path(path, path)
  end
  
  def load_recursive_from_path(path, current_path)
    Dir["#{current_path}/*/"].each do |sub_path|
      load_all_from_path(path, sub_path[0...-1])
      load_recursive_from_path(path, sub_path)
    end
  end
  
  def load_all_from_path(base_path, path)
    Dir["#{path}/*.png"].each do |filename|
      @files[filename.downcase.sub(/^#{base_path}\//i, '').sub(/\.[^.]+$/, '')] = File.binread(filename)
    end
  end
  
  def self.start(origin_vd, target_vd, path, no_recursive)
    new(origin_vd, target_vd, path, no_recursive)
  end
end

module DataBuilder
  
  module_function
  
  def start(release_path)
    # puts 'Copy dialogs'
    # Dir['Data/Text/Dialogs/*.dat'].each { |filename| File.copy_stream(filename, File.join(release_path, filename)) }
    puts 'Building Data'
    map_files, data_files = get_data_files
    make_vd(File.join(release_path, 'Data/0.dat'), data_files)
    make_vd(File.join(release_path, 'Data/1.dat'), map_files)
    make_vd(File.join(release_path, 'Data/2.dat'), Dir['Data/Text/Dialogs/*.dat'])
    make_vd(File.join(release_path, 'Data/3.dat'), Dir['Data/PSDK/*.rxdata'])
    make_vd(File.join(release_path, 'Data/4.dat'), Dir['Data/Animations/*.dat'] << 'Data/Animations/splash.psdkanim')
    make_vd(File.join(release_path, 'Data/5.dat'), Dir['Data/MapNavigation/*.mapnav'])
  end
  
  def make_vd(filename, files)
    vd = Yuki::VD.new(filename, :write)
    files.each do |filename|
      next unless File.exist?(filename)
      puts filename
      vd.write_data(File.basename(filename).downcase, File.binread(filename))
    end
    vd.close
  end
  
  def get_data_files
    data_files = Dir['Data/*.*']
    data_files.delete('Data/Scripts.rxdata')
    data_files.delete('Data/PSDK_BOOT.rxdata')
    data_files.delete('Data/PSDK_BOOT.rb')
    data_files.delete('Data/Animations-original.rxdata')
    data_files.delete('Data/Animations.psdk')
    map_files = data_files.grep(/^Data\/Map/)
    data_files -= map_files
    return map_files, data_files
  end
end

rgss_main {}

ProjectCompilation.start
