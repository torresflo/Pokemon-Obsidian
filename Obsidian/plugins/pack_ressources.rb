#encoding: utf-8

#> Prevent the game from launching
$GAME_LOOP = proc {}

Dir.mkdir(PSDK_PATH) unless Dir.exist?(PSDK_PATH)
PSDK_MASTER = PSDK_PATH + '/master'
Dir.mkdir(PSDK_MASTER) unless Dir.exist?(PSDK_MASTER)

def build_archive(filename, path, files, level = 2)
  level.times do Dir.chdir('..') end
  return if File.exist?("#{PSDK_MASTER}/#{filename}")
  vd = Yuki::VD.new("#{PSDK_MASTER}/#{filename}", :write)
  files.each do |filename|
    vd.write_data(filename.downcase.gsub(/\.[^.]*$/,''), File.open("#{path}/#{filename}", 'rb') do |f| f.read end)
    puts filename
  end
  vd.close
end

Dir.chdir('graphics/animations')
build_archive('animation', 'graphics/animations', Dir['*.png'])
Dir.chdir('graphics/autotiles')
build_archive('autotile', 'graphics/autotiles', Dir['*.png'])
Dir.chdir('graphics/ball')
build_archive('ball', 'graphics/ball', Dir['*.png'])
Dir.chdir('graphics/battlebacks')
build_archive('battleback', 'graphics/battlebacks', Dir['*.png'])
Dir.chdir('graphics/battlers')
build_archive('battler', 'graphics/battlers', Dir['*.png'])
Dir.chdir('graphics/characters')
build_archive('character', 'graphics/characters', Dir['*.png'])
Dir.chdir('graphics/fogs')
build_archive('fog', 'graphics/fogs', Dir['*.png'])
Dir.chdir('graphics/icons')
build_archive('icon', 'graphics/icons', Dir['*.png'])
Dir.chdir('graphics/interface')
build_archive('interface', 'graphics/interface', Dir['*.png'] + Dir['*/*.png'])
Dir.chdir('graphics/panoramas')
build_archive('panorama', 'graphics/panoramas', Dir['*.png'])
Dir.chdir('graphics/particles')
build_archive('particle', 'graphics/particles', Dir['*.png'])
Dir.chdir('graphics/pc')
build_archive('pc', 'graphics/pc', Dir['*.png'])
Dir.chdir('graphics/pictures')
build_archive('picture', 'graphics/pictures', Dir['*.png'])
Dir.chdir('graphics/pokedex')
build_archive('pokedex', 'graphics/pokedex', Dir['*.png'])
Dir.chdir('graphics/titles')
build_archive('title', 'graphics/titles', Dir['*.png'])
Dir.chdir('graphics/tilesets')
build_archive('tileset', 'graphics/tilesets', Dir['*.png'])
Dir.chdir('graphics/transitions')
build_archive('transition', 'graphics/transitions', Dir['*.png'])
Dir.chdir('graphics/windowskins')
build_archive('windowskin', 'graphics/windowskins', Dir['*.png'])
Dir.chdir('graphics/pokedex/FootPrints')
build_archive('foot_print', 'graphics/pokedex/FootPrints', Dir['*.png'], 3)
Dir.chdir('graphics/pokedex/PokeIcon')
build_archive('b_icon', 'graphics/pokedex/PokeIcon', Dir['*.png'], 3)
Dir.chdir('graphics/pokedex/PokeFront')
build_archive('poke_front', 'graphics/pokedex/PokeFront', Dir['*.png'], 3)
Dir.chdir('graphics/pokedex/PokeFrontShiny')
build_archive('poke_front_s', 'graphics/pokedex/PokeFrontShiny', Dir['*.png'], 3)
Dir.chdir('graphics/pokedex/PokeBack')
build_archive('poke_back', 'graphics/pokedex/PokeBack', Dir['*.png'], 3)
Dir.chdir('graphics/pokedex/PokeBackShiny')
build_archive('poke_back_s', 'graphics/pokedex/PokeBackShiny', Dir['*.png'], 3)