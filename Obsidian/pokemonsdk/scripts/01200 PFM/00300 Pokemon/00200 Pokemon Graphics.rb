module PFM
  class Pokemon
    # Name of the EGG image used as image when it's using the ID of the Pokemon
    EGG_NAME_ID = 'egg_%03d'
    # Name of the generic EGG image
    EGG_NAME = 'egg'
    # Name of the form female battler
    FEMALE_NAME_FORM = '%03df_%02d'
    # Name of the female battler
    FEMALE_NAME = '%03df'
    # Name of the  form Male battler
    MALE_NAME_FORM = '%03d_%02d'
    # Name of the Male battler
    MALE_NAME = '%03d'
    # Name of the Shiny
    SHINY_NAME = '%03ds'
    # Name of the Shiny female
    SHINY_FEMALE_NAME = '%03dfs'
    # Name of the Shiny form
    SHINY_NAME_FORM = '%03ds_%02d'
    # Name of the Shiny female form
    SHINY_FEMALE_NAME_FORM = '%03dfs_%02d'
    # Size of a battler
    BATTLER_SIZE = 96
    # Size of an icon
    ICON_SIZE = 32
    # Size of a footprint
    FOOT_SIZE = 16

    # Return the ball image of the Pokemon
    # @return [Bitmap]
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
        return (test_icon(EGG_NAME_ID, id) || EGG_NAME) if egg

        if form > 0
          if female
            filename = test_icon(SHINY_FEMALE_NAME_FORM, id, form) if shiny
            filename ||= test_icon(FEMALE_NAME_FORM, id, form)
          end
          filename ||= test_icon(SHINY_NAME_FORM, id, form) if shiny
          filename ||= test_icon(MALE_NAME_FORM, id, form)
        end
        if female
          filename ||= test_icon(SHINY_FEMALE_NAME, id) if shiny
          filename ||= test_icon(FEMALE_NAME, id)
        end
        filename ||= test_icon(SHINY_NAME, id) if shiny
        filename ||= test_icon(MALE_NAME, id)
        return filename || '000'
      end

      # Return the front battler name
      # @param id [Integer] ID of the Pokemon
      # @param form [Integer] form index of the Pokemon
      # @param female [Boolean] if the Pokemon is a female
      # @param shiny [Boolean] shiny state of the Pokemon
      # @param egg [Boolean] egg state of the Pokemon
      # @return [String]
      def front_filename(id, form, female, shiny, egg)
        return (test_front(0, EGG_NAME_ID, id) || EGG_NAME) if egg

        hue = shiny ? 1 : 0
        if form > 0
          filename = test_front(hue, FEMALE_NAME_FORM, id, form) if female
          filename ||= test_front(hue, MALE_NAME_FORM, id, form)
        end
        filename ||= test_front(hue, FEMALE_NAME, id) if female
        filename ||= test_front(hue, MALE_NAME, id)
        return filename || '000'
      end

      # Return the back battle of the Pokemon
      # @param id [Integer] ID of the Pokemon
      # @param form [Integer] form index of the Pokemon
      # @param female [Boolean] if the Pokemon is a female
      # @param shiny [Boolean] shiny state of the Pokemon
      # @param egg [Boolean] egg state of the Pokemon
      # @return [String]
      def back_filename(id, form, female, shiny, egg)
        return (test_back(0, EGG_NAME_ID, @id) || EGG_NAME) if egg

        hue = shiny ? 1 : 0
        if form > 0
          filename = test_back(hue, FEMALE_NAME_FORM, id, form) if female
          filename ||= test_back(hue, MALE_NAME_FORM, id, form)
        end
        filename ||= test_back(hue, FEMALE_NAME, id) if female
        filename ||= test_back(hue, MALE_NAME, id)
        return filename || '000'
      end

      private

      # Try to get an icon filename
      # @param args [Array] the format command parameters
      # @return [String, nil]
      def test_icon(*args)
        RPG::Cache.b_icon_exist?(filename = format(*args)) ? filename : nil
      end

      # Try to get a front filename
      # @param hue [Integer] the hue asked
      # @param args [Array] the format command parameters
      # @return [String, nil]
      def test_front(hue, *args)
        RPG::Cache.poke_front_exist?(filename = format(*args), hue) ? filename : nil
      end

      # Try to get a back filename
      # @param hue [Integer] the hue asked
      # @param args [Array] the format command parameters
      # @return [String, nil]
      def test_back(hue, *args)
        RPG::Cache.poke_back_exist?(filename = format(*args), hue) ? filename : nil
      end
    end

    # Return the icon of the Pokemon
    # @return [Bitmap]
    def icon
      return RPG::Cache.b_icon(PFM::Pokemon.icon_filename(id, form, female?, shiny?, egg?))
    end

    # Return the front battler of the Pokemon
    # @return [Bitmap]
    def battler_face
      return RPG::Cache.poke_front(PFM::Pokemon.front_filename(id, form, female?, shiny?, egg?), shiny? ? 1 : 0)
    end
    alias battler_front battler_face

    # Return the back battle of the Pokemon
    # @return [Bitmap]
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
      if @step_remaining>0
        return nil
      end
      hue = shiny? ? "Shiny" : ""
      if(@gender == 2)
        if(@form > 0)
          str = sprintf("Graphics/Pokedex/PokeFront%s/%03df_%02d.gif", hue, @id , @form)
          return ::Yuki::GifReader.new(str) if File.exist?(str)
        end
        str = sprintf("Graphics/Pokedex/PokeFront%s/%03df.gif", hue, @id)
        return ::Yuki::GifReader.new(str) if File.exist?(str)
      end
      if(@form > 0)
        str = sprintf("Graphics/Pokedex/PokeFront%s/%03d_%02d.gif", hue, @id, @form)
        return ::Yuki::GifReader.new(str) if File.exist?(str)
      end
      str = sprintf("Graphics/Pokedex/PokeFront%s/%03d.gif", hue, @id)
      return ::Yuki::GifReader.new(str) if File.exist?(str)
      return nil
    end

    # Return the GifReader back of the Pokemon
    # @return [::Yuki::GifReader, nil]
    def gif_back
      if @step_remaining>0
        return nil
      end
      hue = shiny? ? "Shiny" : ""
      if(@gender == 2)
        if(@form > 0)
          str = sprintf("Graphics/Pokedex/PokeBack%s/%03df_%02d.gif", hue, @id , @form)
          return ::Yuki::GifReader.new(str) if File.exist?(str)
        end
        str = sprintf("Graphics/Pokedex/PokeBack%s/%03df.gif", hue, @id)
        return ::Yuki::GifReader.new(str) if File.exist?(str)
      end
      if(@form > 0)
        str = sprintf("Graphics/Pokedex/PokeBack%s/%03d_%02d.gif", hue, @id, @form)
        return ::Yuki::GifReader.new(str) if File.exist?(str)
      end
      str = sprintf("Graphics/Pokedex/PokeBack%s/%03d.gif", hue, @id)
      return ::Yuki::GifReader.new(str) if File.exist?(str)
      return nil
    end
  end
end
