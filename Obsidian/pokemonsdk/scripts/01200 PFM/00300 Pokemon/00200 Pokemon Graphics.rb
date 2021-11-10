module PFM
  class Pokemon
    # All possible attempt of finding an egg
    EGG_FILENAMES = ['egg_%<id>03d_%<form>02d', 'egg_%<id>03d', 'egg_%<name>s_%<form>02d', 'egg_%<name>s', 'egg']
    # All possible attempt of finding a sprite filename
    SPRITES_FILENAMES = {
      female: ['%<id>03df_%<form>02d', '%<id>03df', '%<name>s_female_%<form>02d', '%<name>s_female'],
      default: ['%<id>03d_%<form>02d', '%<id>03d', '%<name>s_%<form>02d', '%<name>s']
    }
    # All possible attempt of finding a gif filename
    GIF_FILENAMES = {
      female: ['%<id>03df_%<form>02d.gif', '%<id>03df.gif', '%<name>s_female_%<form>02d.gif', '%<name>s_female.gif'],
      default: ['%<id>03d_%<form>02d.gif', '%<id>03d.gif', '%<name>s_%<form>02d.gif', '%<name>s.gif']
    }
    # All possible attempt of finding a icon filename
    ICON_FILENAMES = {
      female_shiny: ['%<id>03dfs_%<form>02d', '%<id>03dfs', '%<name>s_female_shiny_%<form>02d', '%<name>s_female_shiny'],
      default_shiny: ['%<id>03ds_%<form>02d', '%<id>03ds', '%<name>s_shiny_%<form>02d', '%<name>s_shiny'],
      **SPRITES_FILENAMES
    }
    # All the sprite collection to check depending on the female & shiny couple
    SPRITES_TO_CHECK = [
      %i[default], # Nothing
      %i[default_shiny default], # Shiny
      %i[female default], # Female
      %i[female_shiny default_shiny female default] # Female + Shiny
    ]
    # Size of a battler
    BATTLER_SIZE = 96
    # Size of an icon
    ICON_SIZE = 32
    # Size of a footprint
    FOOT_SIZE = 16

    # Return the ball image of the Pokemon
    # @return [Texture]
    def ball_image
      return RPG::Cache.ball(ball_sprite)
    end

    class << self
      # Icon filename of a Pokemon
      # @param id [Integer] ID of the Pokemon
      # @param form [Integer] form index of the Pokemon
      # @param female [Boolean] if the Pokemon is a female
      # @param shiny [Boolean] shiny state of the Pokemon
      # @param egg [Boolean] egg state of the Pokemon
      # @return [String]
      def icon_filename(id, form, female, shiny, egg)
        format_arg = { id: id, form: form, name: GameData::Pokemon[id].db_symbol }
        cache_exist = RPG::Cache.method(:b_icon_exist?)
        return correct_filename_from(EGG_FILENAMES, format_arg, cache_exist) || EGG_FILENAMES.last if egg

        check_index = shiny ? 1 : 0
        check_index += 2 if female

        SPRITES_TO_CHECK[check_index].each do |symbol|
          filename = correct_filename_from(ICON_FILENAMES[symbol], format_arg, cache_exist)
          return filename if filename
        end

        return '000'
      end

      # Return the front battler name
      # @param id [Integer] ID of the Pokemon
      # @param form [Integer] form index of the Pokemon
      # @param female [Boolean] if the Pokemon is a female
      # @param shiny [Boolean] shiny state of the Pokemon
      # @param egg [Boolean] egg state of the Pokemon
      # @return [String]
      def front_filename(id, form, female, shiny, egg)
        format_arg = { id: id, form: form, name: GameData::Pokemon[id].db_symbol }
        return correct_filename_from(EGG_FILENAMES, format_arg, RPG::Cache.method(:poke_front_exist?)) || EGG_FILENAMES.last if egg

        hue = shiny ? 1 : 0
        cache_exist = proc { |filename| RPG::Cache.poke_front_exist?(filename, hue) }
        filename = correct_filename_from(SPRITES_FILENAMES[:female], format_arg, cache_exist) if female
        filename ||= correct_filename_from(SPRITES_FILENAMES[:default], format_arg, cache_exist)

        return filename || '000'
      end

      # Return the front gif name
      # @param id [Integer] ID of the Pokemon
      # @param form [Integer] form index of the Pokemon
      # @param female [Boolean] if the Pokemon is a female
      # @param shiny [Boolean] shiny state of the Pokemon
      # @param egg [Boolean] egg state of the Pokemon
      # @return [String, nil]
      def front_gif_filename(id, form, female, shiny, egg)
        format_arg = { id: id, form: form, name: GameData::Pokemon[id].db_symbol }
        hue = shiny ? 1 : 0
        cache_exist = proc { |filename| RPG::Cache.poke_front_exist?(filename, hue) }
        filename = correct_filename_from(GIF_FILENAMES[:female], format_arg, cache_exist) if female
        return filename || correct_filename_from(GIF_FILENAMES[:default], format_arg, cache_exist)
      end

      # Return the back battler name
      # @param id [Integer] ID of the Pokemon
      # @param form [Integer] form index of the Pokemon
      # @param female [Boolean] if the Pokemon is a female
      # @param shiny [Boolean] shiny state of the Pokemon
      # @param egg [Boolean] egg state of the Pokemon
      # @return [String]
      def back_filename(id, form, female, shiny, egg)
        format_arg = { id: id, form: form, name: GameData::Pokemon[id].db_symbol }
        return correct_filename_from(EGG_FILENAMES, format_arg, RPG::Cache.method(:poke_back_exist?)) || EGG_FILENAMES.last if egg

        hue = shiny ? 1 : 0
        cache_exist = proc { |filename| RPG::Cache.poke_back_exist?(filename, hue) }
        filename = correct_filename_from(SPRITES_FILENAMES[:female], format_arg, cache_exist) if female
        filename ||= correct_filename_from(SPRITES_FILENAMES[:default], format_arg, cache_exist)

        return filename || '000'
      end

      # Return the back gif name
      # @param id [Integer] ID of the Pokemon
      # @param form [Integer] form index of the Pokemon
      # @param female [Boolean] if the Pokemon is a female
      # @param shiny [Boolean] shiny state of the Pokemon
      # @param egg [Boolean] egg state of the Pokemon
      # @return [String, nil]
      def back_gif_filename(id, form, female, shiny, egg)
        format_arg = { id: id, form: form, name: GameData::Pokemon[id].db_symbol }
        hue = shiny ? 1 : 0
        cache_exist = proc { |filename| RPG::Cache.poke_back_exist?(filename, hue) }
        filename = correct_filename_from(GIF_FILENAMES[:female], format_arg, cache_exist) if female
        return filename || correct_filename_from(GIF_FILENAMES[:default], format_arg, cache_exist)
      end

      private

      # Find the correct filename in a collection
      # @param formats [Array<String>]
      # @param format_arg [Hash]
      # @param cache_exist [Method, Proc]
      # @return [String, nil] formated filename if it exists
      def correct_filename_from(formats, format_arg, cache_exist)
        formats.each do |filename_format|
          filename = format(filename_format, format_arg)
          return filename if cache_exist.call(filename)
        end

        return nil
      end
    end

    # Return the icon of the Pokemon
    # @return [Texture]
    def icon
      return RPG::Cache.b_icon(PFM::Pokemon.icon_filename(id, form, female?, shiny?, egg?))
    end

    # Return the front battler of the Pokemon
    # @return [Texture]
    def battler_face
      return RPG::Cache.poke_front(PFM::Pokemon.front_filename(id, form, female?, shiny?, egg?), shiny? ? 1 : 0)
    end
    alias battler_front battler_face

    # Return the back battle of the Pokemon
    # @return [Texture]
    def battler_back
      return RPG::Cache.poke_back(PFM::Pokemon.back_filename(id, form, female?, shiny?, egg?), shiny? ? 1 : 0)
    end

    # Return the front offset y of the Pokemon
    # @return [Integer]
    def front_offset_y
      return data.front_offset_y
    end

    # Return the character name of the Pokemon
    # @return [String]
    def character_name
      unless @character
        character = nil
        if female?
          character = sprintf("%03df%s_%d", id, shiny? ? "s" : nil, form)
          character = nil unless RPG::Cache.character_exist?(character)
        end
        unless character
          character = sprintf("%03d%s_%d", id, shiny? ? "s" : nil, form)
          unless RPG::Cache.character_exist?(character)
            character = sprintf("%03d%s_0", id, shiny? ? "s" : nil)
            character = sprintf("%03d_0", id) unless RPG::Cache.character_exist?(character)
          end
        end
        @character = character
      end
      return @character
    end

    # Return the cry file name of the Pokemon
    # @return [String]
    def cry
      return nil.to_s if @step_remaining > 0
      with_form = format('Audio/SE/Cries/%03d_%02dCry.ogg', @id, @form)
      return with_form if File.exist?(with_form)
      with_form = format('Audio/SE/Cries/%03d_%02dCry.wav', @id, @form)
      return with_form if File.exist?(with_form)
      return format('Audio/SE/Cries/%03dCry', @id)
    end

    # Return the GifReader face of the Pokemon
    # @return [::Yuki::GifReader, nil]
    def gif_face
      return nil unless @step_remaining

      filename = Pokemon.front_gif_filename(@id, @form, female?, shiny?, false)
      return filename && Yuki::GifReader.new(RPG::Cache.poke_front(filename, shiny? ? 1 : 0), true)
    end

    # Return the GifReader back of the Pokemon
    # @return [::Yuki::GifReader, nil]
    def gif_back
      return nil unless @step_remaining

      filename = Pokemon.back_gif_filename(@id, @form, female?, shiny?, false)
      return filename && Yuki::GifReader.new(RPG::Cache.poke_back(filename, shiny? ? 1 : 0), true)
    end
  end
end
