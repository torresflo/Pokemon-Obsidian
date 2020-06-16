module RPG
  # Script that cache bitmaps when they are reusable.
  # @author Nuri Yuri
  module Cache
    # Array of load methods to call when the game starts
    LOADS = %i[load_animation load_autotile load_ball load_battleback load_battler load_character load_fog load_icon
               load_panorama load_particle load_pc load_picture load_pokedex load_title load_tileset
               load_transition load_interface load_foot_print load_b_icon load_poke_front load_poke_back]
    # Common filename of the image to load
    Common_filename = 'Graphics/%s/%s'
    # Common filename with .png
    Common_filename_format = format('%s.png', Common_filename)
    # Notification message when an image couldn't be loaded properly
    Notification_title = 'Failed to load graphic'
    # Path where autotiles are stored from Graphics
    Autotiles_Path = 'autotiles'
    # Path where animations are stored from Graphics
    Animations_Path = 'animations'
    # Path where ball are stored from Graphics
    Ball_Path = 'ball'
    # Path where battlebacks are stored from Graphics
    BattleBacks_Path = 'battlebacks'
    # Path where battlers are stored from Graphics
    Battlers_Path = 'battlers'
    # Path where characters are stored from Graphics
    Characters_Path = 'characters'
    # Path where fogs are stored from Graphics
    Fogs_Path = 'fogs'
    # Path where icons are stored from Graphics
    Icons_Path = 'icons'
    # Path where interface are stored from Graphics
    Interface_Path = 'interface'
    # Path where panoramas are stored from Graphics
    Panoramas_Path = 'panoramas'
    # Path where particles are stored from Graphics
    Particles_Path = 'particles'
    # Path where pc are stored from Graphics
    PC_Path = 'pc'
    # Path where pictures are stored from Graphics
    Pictures_Path = 'pictures'
    # Path where pokedex images are stored from Graphics
    Pokedex_Path = 'pokedex'
    # Path where titles are stored from Graphics
    Titles_Path = 'titles'
    # Path where tilesets are stored from Graphics
    Tilesets_Path = 'tilesets'
    # Path where transitions are stored from Graphics
    Transitions_Path = 'transitions'
    # Path where windowskins are stored from Graphics
    Windowskins_Path = 'windowskins'
    # Path where footprints are stored from Graphics
    Pokedex_FootPrints_Path = 'pokedex/footprints'
    # Path where pokeicon are stored from Graphics
    Pokedex_PokeIcon_Path = 'pokedex/pokeicon'
    # Path where pokefront are stored from Graphics
    Pokedex_PokeFront_Path = ['pokedex/pokefront', 'pokedex/pokefrontshiny']
    # Path where pokeback are stored from Graphics
    Pokedex_PokeBack_Path = ['pokedex/pokeback', 'pokedex/pokebackshiny']

    module_function

    # Gets the default bitmap
    # @note Should be used in scripts that require a bitmap be doesn't perform anything on the bitmap
    def default_bitmap
      @default_bitmap = Bitmap.new(16, 16) if @default_bitmap&.disposed?
      @default_bitmap
    end

    # Dispose every bitmap of a cache table
    # @param cache_tab [Hash{String => Bitmap}] cache table where bitmaps should be disposed
    def dispose_bitmaps_from_cache_tab(cache_tab)
      cache_tab.each_value { |bitmap| bitmap.dispose if bitmap && !bitmap.disposed? }
      cache_tab.clear
    end

    # Test if a file exist
    # @param filename [String] filename of the image
    # @param path [String] path of the image inside Graphics/
    # @param file_data [Yuki::VD] "virtual directory"
    # @return [Boolean] if the image exist or not
    def test_file_existence(filename, path, file_data = nil)
      return true if file_data&.exists?(filename.downcase)
      return true if File.exist?(format(Common_filename_format, path, filename).downcase)
      false
    end

    # Loads an image (from cache, disk or virtual directory)
    # @param cache_tab [Hash{String => Bitmap}] cache table where bitmaps are being stored
    # @param filename [String] filename of the image
    # @param path [String] path of the image inside Graphics/
    # @param file_data [Yuki::VD] "virtual directory"
    # @param image_class [Class] Bitmap or Image depending on the desired process
    # @return [Bitmap]
    # @note This function displays a desktop notification if the image is not found.
    #       The resultat bitmap is an empty 16x16 bitmap in this case.
    def load_image(cache_tab, filename, path, file_data = nil, image_class = Bitmap)
      complete_filename = format(Common_filename, path, filename).downcase
      return bitmap = image_class.new(16, 16) if File.directory?(complete_filename) || filename.empty?
      bitmap = cache_tab.fetch(filename, nil)
      if !bitmap || bitmap.disposed?
        filename_ext = complete_filename + '.png'
        if File.exist?(filename_ext) || !file_data.exists?(filename.downcase)
          bitmap = image_class.new(filename_ext)
        end
        bitmap = load_image_from_file_data(filename, file_data, image_class) if (!bitmap || bitmap.disposed?) && file_data
        bitmap ||= image_class.new(16, 16)
      end
      return bitmap
    rescue StandardError
      log_error "#{Notification_title} #{complete_filename}"
      return bitmap = image_class.new("\x89PNG\r\n\x1A\n\x00\x00\x00\rIHDR\x00\x00\x00 \x00\x00\x00 \x02\x03\x00\x00\x00\x0E\x14\x92g\x00\x00\x00\tPLTE\x00\x00\x00\xFF\xFF\xFF\xFF\x00\x00\xCD^\xB7\x9C\x00\x00\x00>IDATx\x01\x85\xCF1\x0E\x00 \bCQ\x17\xEF\xE7\xD2\x85\xFB\xB1\xF4\x94&$Fm\a\xFE\xF4\x06B`x\x13\xD5z\xC0\xEA\a H \x04\x91\x02\xD2\x01E\x9E\xCD\x17\xD1\xC3/\xECg\xECSk\x03[\xAFg\x99\xE2\xED\xCFV\x00\x00\x00\x00IEND\xAEB`\x82", true)
    ensure
      cache_tab[filename] = bitmap
    end

    # Loads an image from virtual directory with the right encoding
    # @param filename [String] filename of the image
    # @param file_data [Yuki::VD] "virtual directory"
    # @param image_class [Class] Bitmap or Image depending on the desired process
    # @return [Bitmap] the image loaded from the virtual directory
    def load_image_from_file_data(filename, file_data, image_class)
      bitmap_data = file_data.read_data(filename.downcase)
      bitmap = image_class.new(bitmap_data, true) if bitmap_data
      bitmap
    end

    # Load/unload the animation cache
    # @param flush_it [Boolean] if we need to flush the cache
    def load_animation(flush_it = false)
      if flush_it
        dispose_bitmaps_from_cache_tab(@animation_cache)
      else
        @animation_cache = {}
        @animation_data = Yuki::VD.new(PSDK_PATH + '/master/animation', :read)
      end
    end

    # Test if the image exist in the folder
    # @param filename [String]
    # @return [Boolean]
    def animation_exist?(filename)
      test_file_existence(filename, Animations_Path, @animation_data)
    end

    # Load an animation image
    # @param filename [String] name of the image in the folder
    # @param _hue [Integer] ingored (compatibility with RMXP)
    # @return [Bitmap]
    def animation(filename, _hue = 0)
      load_image(@animation_cache, filename, Animations_Path, @animation_data)
    end

    # Load/unload the autotile cache
    # @param flush_it [Boolean] if we need to flush the cache
    def load_autotile(flush_it = false)
      if flush_it
        dispose_bitmaps_from_cache_tab(@autotile_cache)
      else
        @autotile_cache = {}
        @autotile_data = Yuki::VD.new(PSDK_PATH + '/master/autotile', :read)
      end
    end

    # Test if the image exist in the folder
    # @param filename [String]
    # @return [Boolean]
    def autotile_exist?(filename)
      test_file_existence(filename, Autotiles_Path, @autotile_data)
    end

    # Load an autotile image
    # @param filename [String] name of the image in the folder
    # @param _hue [Integer] ingored (compatibility with RMXP)
    # @return [Bitmap]
    def autotile(filename, _hue = 0)
      load_image(@autotile_cache, filename, Autotiles_Path, @autotile_data)
    end

    # Load/unload the ball cache
    # @param flush_it [Boolean] if we need to flush the cache
    def load_ball(flush_it = false)
      if flush_it
        dispose_bitmaps_from_cache_tab(@ball_cache)
      else
        @ball_cache = {}
        @ball_data = Yuki::VD.new(PSDK_PATH + '/master/ball', :read)
      end
    end

    # Test if the image exist in the folder
    # @param filename [String]
    # @return [Boolean]
    def ball_exist?(filename)
      test_file_existence(filename, Ball_Path, @ball_data)
    end

    # Load ball animation image
    # @param filename [String] name of the image in the folder
    # @param _hue [Integer] ingored (compatibility with RMXP)
    # @return [Bitmap]
    def ball(filename, _hue = 0)
      load_image(@ball_cache, filename, Ball_Path, @ball_data)
    end

    # Load/unload the battleback cache
    # @param flush_it [Boolean] if we need to flush the cache
    def load_battleback(flush_it = false)
      if flush_it
        dispose_bitmaps_from_cache_tab(@battleback_cache)
      else
        @battleback_cache = {}
        @battleback_data = Yuki::VD.new(PSDK_PATH + '/master/battleback', :read)
      end
    end

    # Test if the image exist in the folder
    # @param filename [String]
    # @return [Boolean]
    def battleback_exist?(filename)
      test_file_existence(filename, BattleBacks_Path, @battleback_data)
    end

    # Load a battle back image
    # @param filename [String] name of the image in the folder
    # @param _hue [Integer] ingored (compatibility with RMXP)
    # @return [Bitmap]
    def battleback(filename, _hue = 0)
      load_image(@battleback_cache, filename, BattleBacks_Path, @battleback_data)
    end

    # Load/unload the battler cache
    # @param flush_it [Boolean] if we need to flush the cache
    def load_battler(flush_it = false)
      if flush_it
        dispose_bitmaps_from_cache_tab(@battler_cache)
      else
        @battler_cache = {}
        @battler_data = Yuki::VD.new(PSDK_PATH + '/master/battler', :read)
      end
    end

    # Test if the image exist in the folder
    # @param filename [String]
    # @return [Boolean]
    def battler_exist?(filename)
      test_file_existence(filename, Battlers_Path, @battler_data)
    end

    # Load a battler image
    # @param filename [String] name of the image in the folder
    # @param _hue [Integer] ingored (compatibility with RMXP)
    # @return [Bitmap]
    def battler(filename, _hue = 0)
      load_image(@battler_cache, filename, Battlers_Path, @battler_data)
    end

    # Load/unload the character cache
    # @param flush_it [Boolean] if we need to flush the cache
    def load_character(flush_it = false)
      if flush_it
        dispose_bitmaps_from_cache_tab(@character_cache)
      else
        @character_cache = {}
        @character_data = Yuki::VD.new(PSDK_PATH + '/master/character', :read)
      end
    end

    # Test if the image exist in the folder
    # @param filename [String]
    # @return [Boolean]
    def character_exist?(filename)
      test_file_existence(filename, Characters_Path, @character_data)
    end

    # Load a character image
    # @param filename [String] name of the image in the folder
    # @param _hue [Integer] ingored (compatibility with RMXP)
    # @return [Bitmap]
    def character(filename, _hue = 0)
      load_image(@character_cache, filename, Characters_Path, @character_data)
    end

    # Load/unload the fog cache
    # @param flush_it [Boolean] if we need to flush the cache
    def load_fog(flush_it = false)
      if flush_it
        dispose_bitmaps_from_cache_tab(@fog_cache)
      else
        @fog_cache = {}
        @fog_data = Yuki::VD.new(PSDK_PATH + '/master/fog', :read)
      end
    end

    # Test if the image exist in the folder
    # @param filename [String]
    # @return [Boolean]
    def fog_exist?(filename)
      test_file_existence(filename, Fogs_Path, @fog_data)
    end

    # Load a fog image
    # @param filename [String] name of the image in the folder
    # @param _hue [Integer] ingored (compatibility with RMXP)
    # @return [Bitmap]
    def fog(filename, _hue = 0)
      load_image(@fog_cache, filename, Fogs_Path, @fog_data)
    end

    # Load/unload the icon cache
    # @param flush_it [Boolean] if we need to flush the cache
    def load_icon(flush_it = false)
      if flush_it
        dispose_bitmaps_from_cache_tab(@icon_cache)
      else
        @icon_cache = {}
        @icon_data = Yuki::VD.new(PSDK_PATH + '/master/icon', :read)
      end
    end

    # Test if the image exist in the folder
    # @param filename [String]
    # @return [Boolean]
    def icon_exist?(filename)
      test_file_existence(filename, Icons_Path, @icon_data)
    end

    # Load an icon
    # @param filename [String] name of the image in the folder
    # @param _hue [Integer] ingored (compatibility with RMXP)
    # @return [Bitmap]
    def icon(filename, _hue = 0)
      load_image(@icon_cache, filename, Icons_Path, @icon_data)
    end

    # Load/unload the interface cache
    # @param flush_it [Boolean] if we need to flush the cache
    def load_interface(flush_it = false)
      if flush_it
        dispose_bitmaps_from_cache_tab(@interface_cache)
      else
        @interface_cache = {}
        @interface_data = Yuki::VD.new(PSDK_PATH + '/master/interface', :read)
      end
    end

    # Test if the image exist in the folder
    # @param filename [String]
    # @return [Boolean]
    def interface_exist?(filename)
      test_file_existence(filename, Interface_Path, @interface_data)
    end

    # Load an interface image
    # @param filename [String] name of the image in the folder
    # @param _hue [Integer] ingored (compatibility with RMXP)
    # @return [Bitmap]
    def interface(filename, _hue = 0)
      if interface_exist?(filename_with_language = filename + ($options&.language || 'en')) ||
         interface_exist?(filename_with_language = filename + 'en')
        filename = filename_with_language
      end
      load_image(@interface_cache, filename, Interface_Path, @interface_data)
    end

    # Load an interface "Image" (to perform some background process)
    # @param filename [String] name of the image in the folder
    # @return [Image]
    def interface_image(filename)
      if interface_exist?(filename_with_language = filename + ($options&.language || 'en')) ||
         interface_exist?(filename_with_language = filename + 'en')
        filename = filename_with_language
      end
      load_image(@interface_cache, filename, Interface_Path, @interface_data, Image)
    end

    # Load/unload the panorama cache
    # @param flush_it [Boolean] if we need to flush the cache
    def load_panorama(flush_it = false)
      if flush_it
        dispose_bitmaps_from_cache_tab(@panorama_cache)
      else
        @panorama_cache = {}
        @panorama_data = Yuki::VD.new(PSDK_PATH + '/master/panorama', :read)
      end
    end

    # Test if the image exist in the folder
    # @param filename [String]
    # @return [Boolean]
    def panorama_exist?(filename)
      test_file_existence(filename, Panoramas_Path, @panorama_data)
    end

    # Load a panorama image
    # @param filename [String] name of the image in the folder
    # @param _hue [Integer] ingored (compatibility with RMXP)
    # @return [Bitmap]
    def panorama(filename, _hue = 0)
      load_image(@panorama_cache, filename, Panoramas_Path, @panorama_data)
    end

    # Load/unload the particle cache
    # @param flush_it [Boolean] if we need to flush the cache
    def load_particle(flush_it = false)
      if flush_it
        dispose_bitmaps_from_cache_tab(@particle_cache)
      else
        @particle_cache = {}
        @particle_data = Yuki::VD.new(PSDK_PATH + '/master/particle', :read)
      end
    end

    # Test if the image exist in the folder
    # @param filename [String]
    # @return [Boolean]
    def particle_exist?(filename)
      test_file_existence(filename, Particles_Path, @particle_data)
    end

    # Load a particle image
    # @param filename [String] name of the image in the folder
    # @param _hue [Integer] ingored (compatibility with RMXP)
    # @return [Bitmap]
    def particle(filename, _hue = 0)
      load_image(@particle_cache, filename, Particles_Path, @particle_data)
    end

    # Load/unload the pc cache
    # @param flush_it [Boolean] if we need to flush the cache
    def load_pc(flush_it = false)
      if flush_it
        dispose_bitmaps_from_cache_tab(@pc_cache)
      else
        @pc_cache = {}
        @pc_data = Yuki::VD.new(PSDK_PATH + '/master/pc', :read)
      end
    end

    # Test if the image exist in the folder
    # @param filename [String]
    # @return [Boolean]
    def pc_exist?(filename)
      test_file_existence(filename, PC_Path, @pc_data)
    end

    # Load a pc image
    # @param filename [String] name of the image in the folder
    # @param _hue [Integer] ingored (compatibility with RMXP)
    # @return [Bitmap]
    def pc(filename, _hue = 0)
      load_image(@pc_cache, filename, PC_Path, @pc_data)
    end

    # Load/unload the picture cache
    # @param flush_it [Boolean] if we need to flush the cache
    def load_picture(flush_it = false)
      if flush_it
        dispose_bitmaps_from_cache_tab(@picture_cache)
      else
        @picture_cache = {}
        @picture_data = Yuki::VD.new(PSDK_PATH + '/master/picture', :read)
      end
    end

    # Test if the image exist in the folder
    # @param filename [String]
    # @return [Boolean]
    def picture_exist?(filename)
      test_file_existence(filename, Pictures_Path, @picture_data)
    end

    # Load a picture image
    # @param filename [String] name of the image in the folder
    # @param _hue [Integer] ingored (compatibility with RMXP)
    # @return [Bitmap]
    def picture(filename, _hue = 0)
      load_image(@picture_cache, filename, Pictures_Path, @picture_data)
    end

    # Load/unload the pokedex cache
    # @param flush_it [Boolean] if we need to flush the cache
    def load_pokedex(flush_it = false)
      if flush_it
        dispose_bitmaps_from_cache_tab(@pokedex_cache)
      else
        @pokedex_cache = {}
        @pokedex_data = Yuki::VD.new(PSDK_PATH + '/master/pokedex', :read)
      end
    end

    # Test if the image exist in the folder
    # @param filename [String]
    # @return [Boolean]
    def pokedex_exist?(filename)
      test_file_existence(filename, Pokedex_Path, @pokedex_data)
    end

    # Load a pokedex image
    # @param filename [String] name of the image in the folder
    # @param _hue [Integer] ingored (compatibility with RMXP)
    # @return [Bitmap]
    def pokedex(filename, _hue = 0)
      load_image(@pokedex_cache, filename, Pokedex_Path, @pokedex_data)
    end

    # Load/unload the title cache
    # @param flush_it [Boolean] if we need to flush the cache
    def load_title(flush_it = false)
      if flush_it
        dispose_bitmaps_from_cache_tab(@title_cache)
      else
        @title_cache = {}
        @title_data = Yuki::VD.new(PSDK_PATH + '/master/title', :read)
      end
    end

    # Test if the image exist in the folder
    # @param filename [String]
    # @return [Boolean]
    def title_exist?(filename)
      test_file_existence(filename, Titles_Path, @title_data)
    end

    # Load a title image
    # @param filename [String] name of the image in the folder
    # @param _hue [Integer] ingored (compatibility with RMXP)
    # @return [Bitmap]
    def title(filename, _hue = 0)
      load_image(@title_cache, filename, Titles_Path, @title_data)
    end

    # Load/unload the tileset cache
    # @param flush_it [Boolean] if we need to flush the cache
    def load_tileset(flush_it = false)
      if flush_it
        dispose_bitmaps_from_cache_tab(@tileset_cache)
      else
        @tileset_cache = {}
        @tileset_data = Yuki::VD.new(PSDK_PATH + '/master/tileset', :read)
      end
    end

    # Test if the image exist in the folder
    # @param filename [String]
    # @return [Boolean]
    def tileset_exist?(filename)
      test_file_existence(filename, Tilesets_Path, @tileset_data)
    end

    # Load a tileset image
    # @param filename [String] name of the image in the folder
    # @param _hue [Integer] ingored (compatibility with RMXP)
    # @return [Bitmap]
    def tileset(filename, _hue = 0)
      load_image(@tileset_cache, filename, Tilesets_Path, @tileset_data)
    end

    # Load a tileset "Image" (to perform some background process)
    # @param filename [String] name of the image in the folder
    # @return [Image]
    def tileset_image(filename)
      load_image(@tileset_cache, filename, Tilesets_Path, @tileset_data, Image)
    end

    # Load/unload the transition cache
    # @param flush_it [Boolean] if we need to flush the cache
    def load_transition(flush_it = false)
      if flush_it
        dispose_bitmaps_from_cache_tab(@transition_cache)
      else
        @transition_cache = {}
        @transition_data = Yuki::VD.new(PSDK_PATH + '/master/transition', :read)
      end
    end

    # Test if the image exist in the folder
    # @param filename [String]
    # @return [Boolean]
    def transition_exist?(filename)
      test_file_existence(filename, Transitions_Path, @transition_data)
    end

    # Load a transition image
    # @param filename [String] name of the image in the folder
    # @param _hue [Integer] ingored (compatibility with RMXP)
    # @return [Bitmap]
    def transition(filename, _hue = 0)
      load_image(@transition_cache, filename, Transitions_Path, @transition_data)
    end

    # Load/unload the windoskin cache
    # @param flush_it [Boolean] if we need to flush the cache
    def load_windowskin(flush_it = false)
      if flush_it
        dispose_bitmaps_from_cache_tab(@windowskin_cache)
      else
        @windowskin_cache = {}
        @windowskin_data = Yuki::VD.new(PSDK_PATH + '/master/windowskin', :read)
      end
    end

    # Test if the image exist in the folder
    # @param filename [String]
    # @return [Boolean]
    def windowskin_exist?(filename)
      test_file_existence(filename, Windowskins_Path, @windowskin_data)
    end

    # Load a windowskin image
    # @param filename [String] name of the image in the folder
    # @param _hue [Integer] ingored (compatibility with RMXP)
    # @return [Bitmap]
    def windowskin(filename, _hue = 0)
      load_image(@windowskin_cache, filename, Windowskins_Path, @windowskin_data)
    end

    # Load/unload the foot print cache
    # @param flush_it [Boolean] if we need to flush the cache
    def load_foot_print(flush_it = false)
      if flush_it
        dispose_bitmaps_from_cache_tab(@foot_print_cache)
      else
        @foot_print_cache = {}
        @foot_print_data = Yuki::VD.new(PSDK_PATH + '/master/foot_print', :read)
      end
    end

    # Test if the image exist in the folder
    # @param filename [String]
    # @return [Boolean]
    def foot_print_exist?(filename)
      test_file_existence(filename, Pokedex_FootPrints_Path, @foot_print_data)
    end

    # Load a foot print image
    # @param filename [String] name of the image in the folder
    # @param _hue [Integer] ingored (compatibility with RMXP)
    # @return [Bitmap]
    def foot_print(filename, _hue = 0)
      load_image(@foot_print_cache, filename, Pokedex_FootPrints_Path, @foot_print_data)
    end

    # Load/unload the pokemon icon cache
    # @param flush_it [Boolean] if we need to flush the cache
    def load_b_icon(flush_it = false)
      if flush_it
        dispose_bitmaps_from_cache_tab(@b_icon_cache)
      else
        @b_icon_cache = {}
        @b_icon_data = Yuki::VD.new(PSDK_PATH + '/master/b_icon', :read)
      end
    end

    # Test if the image exist in the folder
    # @param filename [String]
    # @return [Boolean]
    def b_icon_exist?(filename)
      test_file_existence(filename, Pokedex_PokeIcon_Path, @b_icon_data)
    end

    # Load a Pokemon icon image
    # @param filename [String] name of the image in the folder
    # @param _hue [Integer] ingored (compatibility with RMXP)
    # @return [Bitmap]
    def b_icon(filename, _hue = 0)
      load_image(@b_icon_cache, filename, Pokedex_PokeIcon_Path, @b_icon_data)
    end

    # Load/unload the pokemon front cache
    # @param flush_it [Boolean] if we need to flush the cache
    def load_poke_front(flush_it = false)
      if flush_it
        @poke_front_cache.each { |cache_tab| dispose_bitmaps_from_cache_tab(cache_tab) }
      else
        @poke_front_cache = Array.new(Pokedex_PokeFront_Path.size) { {} }
        @poke_front_data = [
          Yuki::VD.new(PSDK_PATH + '/master/poke_front', :read),
          Yuki::VD.new(PSDK_PATH + '/master/poke_front_s', :read)
        ]
      end
    end

    # Test if the image exist in the folder
    # @param filename [String]
    # @param hue [Integer] if the front is shiny or not
    # @return [Boolean]
    def poke_front_exist?(filename, hue = 0)
      test_file_existence(filename, Pokedex_PokeFront_Path.fetch(hue), @poke_front_data[hue])
    end

    # Load a pokemon face image
    # @param filename [String] name of the image in the folder
    # @param hue [Integer] 0 = normal, 1 = shiny
    # @return [Bitmap]
    def poke_front(filename, hue = 0)
      load_image(@poke_front_cache.fetch(hue), filename, Pokedex_PokeFront_Path.fetch(hue), @poke_front_data[hue])
    end

    # Load/unload the pokemon back cache
    # @param flush_it [Boolean] if we need to flush the cache
    def load_poke_back(flush_it = false)
      if flush_it
        @poke_back_cache.each { |cache_tab| dispose_bitmaps_from_cache_tab(cache_tab) }
      else
        @poke_back_cache = Array.new(Pokedex_PokeBack_Path.size) { {} }
        @poke_back_data = [
          Yuki::VD.new(PSDK_PATH + '/master/poke_back', :read),
          Yuki::VD.new(PSDK_PATH + '/master/poke_back_s', :read)
        ]
      end
    end

    # Test if the image exist in the folder
    # @param filename [String]
    # @param hue [Integer] if the back is shiny or not
    # @return [Boolean]
    def poke_back_exist?(filename, hue = 0)
      test_file_existence(filename, Pokedex_PokeBack_Path.fetch(hue), @poke_back_data[hue])
    end

    # Load a pokemon back image
    # @param filename [String] name of the image in the folder
    # @param hue [Integer] 0 = normal, 1 = shiny
    # @return [Bitmap]
    def poke_back(filename, hue = 0)
      load_image(@poke_back_cache.fetch(hue), filename, Pokedex_PokeBack_Path.fetch(hue), @poke_back_data[hue])
    end

    # Meta defintion of the cache loading without hue (shiny processing)
    Cache_meta_without_hue = <<-CACHE_META_PROGRAMMATION
      LOADS << :load_%<cache_name>s
      %<cache_constant>s_Path = '%<cache_path>s'
      module_function

      def load_%<cache_name>s(flush_it = false)
        unless flush_it
          @%<cache_name>s_cache = {}
          @%<cache_name>s_data = Yuki::VD.new(PSDK_PATH + '/master/%<cache_name>s', :read)
        else
          dispose_bitmaps_from_cache_tab(@%<cache_name>s_cache)
        end
      end

      def %<cache_name>s_exist?(filename)
        test_file_existence(filename, %<cache_constant>s_Path, @%<cache_name>s_data)
      end

      def %<cache_name>s(filename, _hue = 0)
        load_image(@%<cache_name>s_cache, filename, %<cache_constant>s_Path, @%<cache_name>s_data)
      end

      def extract_%<cache_name>s(path = '')
        path += %<cache_constant>s_Path
        ori = Dir.pwd
        Dir.mkdir!(path.downcase)
        Dir.chdir(path.downcase)
        @%<cache_name>s_data.get_filenames.each do |filename|
          if filename.include?('/')
            dirname = File.dirname(filename)
            Dir.mkdir!(dirname) unless Dir.exist?(dirname)
          end
          was_cached = @%<cache_name>s_cache[filename] != nil
          bmp = %<cache_name>s(filename)
          bmp.to_png_file(filename + '.png')
          bmp.dispose unless was_cached
        end
      ensure
        Dir.chdir(ori)
      end
    CACHE_META_PROGRAMMATION
    # Meta definition of the cache loading with hue (shiny processing)
    Cache_meta_with_hue = <<-CACHE_META_PROGRAMMATION
      LOADS << :load_%<cache_name>s
      %<cache_constant>s_Path = [%<cache_path>s]
      module_function

      def load_%<cache_name>s(flush_it = false)
        unless flush_it
          @%<cache_name>s_cache = Array.new(%<cache_constant>s_Path.size) { {} }
          @%<cache_name>s_data = [
            Yuki::VD.new(PSDK_PATH + '/master/%<cache_name>s', :read),
            Yuki::VD.new(PSDK_PATH + '/master/%<cache_name>s_s', :read)]
        else
          @%<cache_name>s_cache.each { |cache_tab| dispose_bitmaps_from_cache_tab(cache_tab) }
        end
      end

      def %<cache_name>s_exist?(filename, hue = 0)
        test_file_existence(filename, %<cache_constant>s_Path.fetch(hue), @%<cache_name>s_data[hue])
      end

      def %<cache_name>s(filename, hue = 0)
        load_image(@%<cache_name>s_cache.fetch(hue), filename, %<cache_constant>s_Path.fetch(hue), @%<cache_name>s_data[hue])
      end

      def extract_%<cache_name>s(path = '', hue = 0)
        path += %<cache_constant>s_Path[hue]
        ori = Dir.pwd
        Dir.mkdir!(path.downcase)
        Dir.chdir(path.downcase)
        @%<cache_name>s_data[hue].get_filenames.each do |filename|
          if filename.include?('/')
            dirname = File.dirname(filename)
            Dir.mkdir!(dirname) unless Dir.exist?(dirname)
          end
          was_cached = @%<cache_name>s_cache[hue][filename] != nil
          bmp = %<cache_name>s(filename, hue)
          bmp.to_png_file(filename + '.png')
          bmp.dispose unless was_cached
        end
      ensure
        Dir.chdir(ori)
      end
    CACHE_META_PROGRAMMATION
    # Execute a meta code generation (undef when done)
    def meta_exec(line, name, constant, path, meta_code = Cache_meta_without_hue)
      module_eval(
        format(
          meta_code,
          cache_name: name,
          cache_constant: constant,
          cache_path: path
        ),
        __FILE__,
        line
      )
    end
    # @!macro [attach] meta_exec
    #   Loads a bitmap from cache or Graphics/$4 directory
    #   @!method $2(filename, hue = 0)
    #   @param filename [String] name of the image in Graphics/$4
    #   @param hue [Integer] hue if the cache has hue (shiny processing)
    #   @return [Bitmap] the bitmap corresponding to the image

    # meta_exec(__LINE__, 'animation', 'Animations', 'Animations')

    # meta_exec(
    #  __LINE__,
    #  'poke_front',
    #  'Pokedex_PokeFront',
    #  "'Pokedex/PokeFront', 'Pokedex/PokeFrontShiny'",
    #  Cache_meta_with_hue
    # )
  end
end

# Tells what to do on Start
Graphics.on_start do
  RPG::Cache::LOADS.each do |k|
    RPG::Cache.send(k)
  end
  RPG::Cache.instance_eval do
    undef meta_exec
    remove_const :Cache_meta_without_hue
    remove_const :Cache_meta_with_hue
  end
end
