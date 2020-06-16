# Class describing the PSDK Config
module ScriptLoader
  class PSDKConfig
    # @return [String] the game title
    attr_reader :game_title
    # @return [Integer] game version
    attr_reader :game_version
    # @return [String] the game resolution
    attr_reader :native_resolution
    # @return [String] default language of the game
    attr_reader :default_language_code
    # @return [Array<String>] list of language the player can choose
    attr_reader :choosable_language_code
    # @return [Array<String>] list of language the player can choose (names)
    attr_reader :choosable_language_texts
    # @return [Integer] number of saves the player can have
    attr_reader :maximum_saves
    # @return [Integer] the window scale
    attr_reader :window_scale
    # @return [Boolean] if the game runs in fullscreen
    attr_reader :running_in_full_screen
    # @return [Boolean] if textures are smooth
    attr_reader :smooth_texture
    # @return [Boolean] if the game runs in VSYNC
    attr_reader :vsync_enabled
    # @return [Integer] the pokemon max level
    attr_reader :pokemon_max_level
    # @return [Boolean] if the player is always centered
    attr_reader :player_always_centered
    # @return [Boolean] if the mouse is disabled
    attr_reader :mouse_disabled
    # If the Pokemon always rely on form 0 for evolution
    # @return [Boolean]
    attr_reader :always_use_form0_for_evolution
    # If the Pokemon can use form 0 when no evolution data is found in current form
    # @return [Boolean]
    attr_reader :use_form0_when_no_evolution_data
    # @return [String, nil] the mouse skind to use
    attr_reader :mouse_skin
    # @return [Boolean] if the game skips title & save loading in debug
    attr_reader :skip_title_in_debug
    # @return [Boolean] if the game skips battle_transition in debug
    attr_reader :skip_battle_transition_in_debug
    # @return [Integer, nil] Specific zoom for overworld things
    attr_reader :specific_zoom
    # @return [Integer] OffsetX of all the viewports
    attr_reader :viewport_offset_x
    # @return [Integer] OffsetY of all the viewports
    attr_reader :viewport_offset_y
    # @return [TilemapConfig] tilemap configurations
    attr_reader :tilemap
    # @return [OptionsConfig] options configuration
    attr_reader :options
    # @return [LayoutConfig] layout configuration
    attr_reader :layout
    # Name of the yaml file
    YAML_FILENAME = 'Data/project_identity.yml'
    # Name of the dat file
    DAT_FILENAME = 'Data/project_identity.rxdata'
    # List of legal aspect ratio
    ALLOWED_RATIOS = [4 / 3r, 16 / 9r, 16 / 10r]
    # Create the PSDK Config
    def initialize
      data = try_to_load_config
      data&.instance_variables&.each do |ivar_name|
        instance_variable_set(ivar_name, data.instance_variable_get(ivar_name))
      end
      fix_variables(!data || should_save)
      adjust_litergss_config
    end

    def copy_past_old_project_identity
      if File.exist?('Data/project_indentity.yml')
        File.copy_stream('Data/project_indentity.yml', YAML_FILENAME)
        File.delete('Data/project_indentity.yml')
      end
    end

    # Tell if the game is in Release mode
    # @return [Boolean]
    def release?
      @release = File.exist?('Data/Scripts.dat') if @release.nil?
      return @release
    end

    # Tell if the game is in Debug mode
    # @return [Boolean]
    def debug?
      @debug = !release? && ARGV.include?('debug') if @debug.nil?
      return @debug
    end

    # Save the full configs
    def save_to_files
      File.write(YAML_FILENAME, YAML.dump(self))
      save_data(self, DAT_FILENAME)
    end

    private

    # Try to load configs from data or yml
    # @return [PSDKConfig]
    def try_to_load_config
      data = load_data(DAT_FILENAME) rescue nil
      if !data || should_save
        data = YAML.load(File.read(YAML_FILENAME)) if File.exist?(YAML_FILENAME)
      end
      return data.is_a?(PSDKConfig) ? data : nil
    end

    # Function that fix the variables
    # @param save [Boolean] if the object should be saved
    def fix_variables(save)
      @game_title = (@game_title || 'Pokémon SDK').to_s
      @game_version = (@game_version || 256).to_i
      @default_language_code = (@default_language_code || 'en').to_s
      @choosable_language_code ||= %w[en fr es]
      @choosable_language_texts ||= %w[English French Spanish]
      @maximum_saves = (@maximum_saves || 4).to_i
      @mouse_skin = nil unless @mouse_skin.is_a?(String)
      fix_resolution
      fix_scale
      fix_full_screen
      fix_smooth_texture
      fix_vsync
      save |= fix_gameplay_config
      save |= !@tilemap.is_a?(TilemapConfig)
      @tilemap = @tilemap.is_a?(TilemapConfig) ? @tilemap : TilemapConfig.new
      save |= @tilemap.fix_missing_values | !@options.is_a?(OptionsConfig) | !@layout.is_a?(LayoutConfig)
      @options = @options.is_a?(OptionsConfig) ? @options : OptionsConfig.new
      @layout = @layout.is_a?(LayoutConfig) ? @layout : LayoutConfig.new
      if save
        remove_instance_variable(:@release) if instance_variable_defined?(:@release)
        remove_instance_variable(:@debug) if instance_variable_defined?(:@debug)
        save_to_files
      end
    end

    # Function that fix the native resolution
    def fix_resolution
      resolution = (@native_resolution || '320x240')
                   .to_s.split('x').collect(&:to_i)[0, 2]
      resolution = [320, 240] unless resolution.size == 2
      ratio = resolution.first.to_r / resolution.last
      unless ALLOWED_RATIOS.include?(ratio)
        puts format('Invalid screen aspect ratio %<top>d:%<bottom>d.', top: ratio.numerator, bottom: ratio.denominator)
      end
      @native_resolution = resolution.join('x')
    end

    # Function that fix the scale
    def fix_scale
      @window_scale = (PARGV[:scale] || @window_scale).to_i
      @window_scale = 2 if @window_scale < 0.1
    end

    # Function that fix the fullscreen
    def fix_full_screen
      param = PARGV[:fullscreen]
      @running_in_full_screen = (param.nil? ? @running_in_full_screen : param) == true
    end

    # Function that fix the smooth_texture
    def fix_smooth_texture
      param = PARGV[:smooth]
      @smooth_texture = (param.nil? ? @smooth_texture : param) == true
    end

    # Function that fix the vsync param
    def fix_vsync
      @vsync_enabled = !PARGV[:"no-vsync"]
    end

    # Function that fix the gameplay config
    # @return [Boolean] if a save is of project_identity is required
    def fix_gameplay_config
      must_save = false
      @pokemon_max_level = (@pokemon_max_level || 100).to_i
      @player_always_centered = @player_always_centered == true
      @mouse_disabled = @mouse_disabled == true
      if @always_use_form0_for_evolution.nil?
        @always_use_form0_for_evolution = false
        must_save = true
      end
      if @use_form0_when_no_evolution_data.nil?
        @use_form0_when_no_evolution_data = true
        must_save = true
      end
      return must_save
    end

    # Function that adjust the liteRGSS configs
    def adjust_litergss_config
      resolution = choose_best_resolution
      param = self
      Config.module_eval do
        remove_const :Title if const_defined?(:Title)
        const_set :Title, param.game_title
        remove_const :ScreenWidth if const_defined?(:ScreenWidth)
        const_set :ScreenWidth, resolution.first
        remove_const :ScreenHeight if const_defined?(:ScreenHeight)
        const_set :ScreenHeight, resolution.last
        remove_const :ScreenScale if const_defined?(:ScreenScale)
        const_set :ScreenScale, param.window_scale
        remove_const :SmoothScreen if const_defined?(:SmoothScreen)
        const_set :SmoothScreen, param.smooth_texture
        remove_const :FullScreen if const_defined?(:FullScreen)
        const_set :FullScreen, param.running_in_full_screen
        remove_const :Vsync if const_defined?(:Vsync)
        const_set :Vsync, param.vsync_enabled
      end
    end

    # Function that choose the best resolution
    # @return [Array<Integer>]
    def choose_best_resolution
      return editors_resolution if running_editor?

      native = @native_resolution.split('x').collect(&:to_i)
      @viewport_offset_x = 0
      @viewport_offset_y = 0
      if @running_in_full_screen
        desired = [native.first * @window_scale, native.last * @window_scale].map(&:round)
        all_res = Graphics.list_resolutions
        return native if all_res.include?(desired)

        if all_res.include?(native)
          @window_scale = 1
          return native
        end
        return find_best_matching_resolution(native, desired, all_res)
      else
        return native
      end
    end

    # Return the editor resolution
    # @return [Array<Integer>]
    def editors_resolution
      @window_scale = 1
      @running_in_full_screen = false
      @viewport_offset_x = 0
      @viewport_offset_y = 0
      return [640, 480]
    end

    # Tell if the game is running an editor
    def running_editor?
      return PARGV[:tags] || PARGV[:worldmap]
    end

    # Function that tries to find the best resolution in all_res according to native & desired
    # @param native [Array<Integer>] native screen resolution
    # @param desired [Array<Integer>] desired screen resolution
    # @param all_res [Array<Array>] all the compatible resolution
    # @return [Array<Integer>]
    def find_best_matching_resolution(native, desired, all_res)
      all_res = all_res.sort # Make sure we can find the first that matches
      unless (desired_res = all_res.find { |res| res.first >= desired.first && res.last >= desired.last })
        @window_scale = 1
        unless (desired_res = all_res.find { |res| res.first >= native.first && res.last >= native.last })
          desired_res = all_res.last
        end
      end
      @viewport_offset_x = ((desired_res.first / @window_scale - native.first) / 2).round
      @viewport_offset_y = ((desired_res.last / @window_scale - native.last) / 2).round
      return [desired_res.first / @window_scale, desired_res.last / @window_scale].map(&:round)
    end

    # Function telling if the game should save the file or not
    # @return [Boolean]
    def should_save
      copy_past_old_project_identity
      return false if release?
      return (!File.exist?(DAT_FILENAME) || !File.exist?(YAML_FILENAME)) ||
             (File.mtime(DAT_FILENAME) < File.mtime(YAML_FILENAME))
    end

    # Class describing the tilemap configuation
    class TilemapConfig
      # @return [String] full constant path of the tilemap class (from Object)
      attr_reader :tilemap_class
      # @return [Integer] number of tile in x to properly show the tilemap
      attr_reader :tilemap_size_x
      # @return [Integer] number of tiles in y to properly show the tilemap
      attr_reader :tilemap_size_y
      # @return [Integer] number of frame an autotile wait before being refreshed
      attr_reader :autotile_idle_frame_count
      # @return [Float] zoom of tiles in sprite character
      attr_reader :character_tile_zoom
      # @return [Integer] player center x value
      attr_reader :center_x
      # @return [Intger] player center y value
      attr_reader :center_y
      # @return [Integer] number of tile in x to make a proper map transition with map linker
      attr_reader :maplinker_offset_x
      # @return [Integer] number of tile in y to make a proper map transition with map linker
      attr_reader :maplinker_offset_y

      # Create a new TilemapConfig
      def initialize
        @tilemap_class = 'Tilemap::WithLessRubySprites_16'
        @tilemap_size_x = 22
        @tilemap_size_y = 17
        @character_tile_zoom = 0.5
        @center_x = (320 - 16) * 4
        @center_y = (240 - 16) * 4
        @maplinker_offset_x = 10
        @maplinker_offset_y = 7
        @autotile_idle_frame_count = 6
      end

      # Function that fix the missing values
      # @return [Boolean] if the files should be saved again
      def fix_missing_values
        return ARGV.include?('debug') && false
      end
    end

    # Class describing the options configuration
    class OptionsConfig
      # @return [Array<Symbol>] option order
      attr_reader :order
      # @return [Array<Array>] options info for the Option scene
      attr_reader :options
      # Create a new OptionsConfig
      def initialize
        @order = %i[message_speed message_frame volume battle_animation battle_style language]
        @options = [
          [
            :message_speed, :choice, [1, 2, 3],
            [
              [:text_get, 42, 4],
              [:text_get, 42, 5],
              [:text_get, 42, 6]
            ],
            [:text_get, 42, 3], [:text_get, 42, 7], :message_speed
          ],
          [
            :message_frame, :choice, 'GameData::Windows::MESSAGE_FRAME', 'GameData::Windows::MESSAGE_FRAME_NAMES',
            [:ext_text, 9000, 165], [:ext_text, 9000, 166], :message_frame
          ],
          [
            :volume, :slider, { min: 0, max: 100, increment: 1 }, '%d%%',
            [:ext_text, 9000, 29], [:ext_text, 9000, 30], :master_volume
          ],
          [
            :battle_animation, :choice, [true, false],
            [
              [:text_get, 42, 9],
              [:text_get, 42, 10]
            ],
            [:text_get, 42, 8], [:text_get, 42, 11], :show_animation
          ],
          [
            :battle_style, :choice, [true, false],
            [
              [:text_get, 42, 13],
              [:text_get, 42, 14]
            ],
            [:text_get, 42, 12], [:text_get, 42, 15], :battle_mode
          ],
          [
            :language, :choice, 'PSDK_CONFIG#choosable_language_code', 'PSDK_CONFIG#choosable_language_texts',
            [:ext_text, 9000, 167], [:ext_text, 9000, 168], :language
          ]
        ]
      end
    end

    # Claas describing the layout configuration
    class LayoutConfig
      # General information about font (loading the fonts, sizes etc...)
      # @return [General]
      attr_reader :general
      # Informations about how to show message according to the scene class
      # @return [Hash{ String => Message }]
      attr_reader :messages
      # Information about how to show the choices according to the scene class
      # @return [Hash{ String => Choice }]
      attr_reader :choices

      # Create a new layout config
      def initialize
        @general = General.new
        @messages = { any: Message.new, 'Battle::Scene' => Message.new }
        @choices = { any: Choice.new }
      end

      # General information about font
      class General
        # If the default font uses special chars as "0123456789" for Pokemon HP number
        # @return [Boolean]
        attr_reader :supports_pokemon_number
        # List of ttf files the game has to load
        # @return [Array]
        attr_reader :ttf_files
        # List of alternative sizing (to prevent loading font for that size, sizeid: should be used in add text to use
        # the said size)
        # @return [Array]
        attr_reader :alt_sizes

        # Create a new General info about font
        def initialize
          @supports_pokemon_number = true
          @ttf_files = [
            { id: 0, name: 'PokemonDS', size: 13, line_height: 16 },
            { id: 1, name: 'PokemonDS', size: 26, line_height: 32 },
            { id: 20, name: 'PowerGreenSmall', size: 11, line_height: 13 }
          ]
          @alt_sizes = [
            { id: 2, size: 22, line_height: 26 },
            { id: 3, size: 13, line_height: 13 }
          ]
        end
      end

      # Information about message
      class Message
        # Force the windowskin regardless of the options
        # @return [String, nil]
        attr_reader :windowskin
        # Force the name window to have a specific windowskin
        # @return [String, nil]
        attr_reader :name_windowskin
        # Number of lines shown by the message
        # @return [Integer]
        attr_reader :line_count
        # Number of pixel between the first pixel of the windowskin
        # @return [Integer]
        attr_reader :border_spacing
        # ID of the font used by the Window
        # @return [Integer]
        attr_reader :default_font
        # ID of the default color
        # @return [Integer]
        attr_reader :default_color
        # Change the color mapping : Mapping from \c[key] to value (x position) in _colors.png
        # @return [Hash{ Integer => Integer }]
        attr_reader :color_mapping

        # Create a new Message information
        def initialize
          @windowskin = nil
          @name_windowskin = nil
          @line_count = 2
          @border_spacing = 2
          @default_font = 0
          @default_color = 0
          @color_mapping = {}
        end
      end

      # Information about choice
      class Choice
        # Force the windowskin regardless of the options
        # @return [String, nil]
        attr_reader :windowskin
        # Number of pixel between the first pixel of the windowskin
        # @return [Integer]
        attr_reader :border_spacing
        # ID of the font used by the Window
        # @return [Integer]
        attr_reader :default_font
        # ID of the default color
        # @return [Integer]
        attr_reader :default_color
        # Change the color mapping : Mapping from \c[key] to value (x position) in _colors.png
        # @return [Hash{ Integer => Integer }]
        attr_reader :color_mapping

        # Create a new Choice information
        def initialize
          @windowskin = nil
          @border_spacing = 2
          @default_font = 0
          @default_color = 0
          @color_mapping = {}
        end
      end
    end
  end
end
# Constant containing all the PSDK Config
PSDK_CONFIG = ScriptLoader::PSDKConfig.new
