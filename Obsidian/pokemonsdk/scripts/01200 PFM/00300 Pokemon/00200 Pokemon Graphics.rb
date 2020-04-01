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
    # Size of a battler
    BATTLER_SIZE = 96
    # Size of an icon
    ICON_SIZE = 32
    # Size of a footprint
    FOOT_SIZE = 16

    # Return the ball image of the Pokemon
    # @return [Bitmap]
    def ball_image
      return RPG::Cache.ball(GameData::Item.ball_data(@captured_with).img)
    end

    # Return the icon of the Pokemon
    # @return [Bitmap]
    def icon
      return (load_icon(EGG_NAME_ID, @id) || RPG::Cache.b_icon(EGG_NAME)) if @step_remaining > 0
      if @form > 0
        bitmap = load_icon(FEMALE_NAME_FORM, @id, @form)
        bitmap ||= load_icon(MALE_NAME_FORM, @id, @form)
      end
      bitmap ||= load_icon(FEMALE_NAME, @id) if @gender == 2
      bitmap ||= load_icon(MALE_NAME, @id)
      return bitmap || RPG::Cache.b_icon('000')
    end

    # Return the cry file name of the Pokemon
    # @return [String]
    def cry
      return nil.to_s if @step_remaining > 0
      with_form = format('Audio/SE/Cries/%03d_%02dCry', @id, @form)
      return with_form if File.exist?(with_form)
      return format('Audio/SE/Cries/%03dCry', @id)
    end

    # Return the front battler of the Pokemon
    # @return [Bitmap]
    def battler_face
      return (load_front(0, EGG_NAME_ID, @id) || RPG::Cache.poke_front(EGG_NAME)) if @step_remaining > 0
      hue = @shiny ? 1 : 0
      if @form > 0
        bitmap = load_front(hue, FEMALE_NAME_FORM, @id, @form) if @gender == 2
        bitmap ||= load_front(hue, MALE_NAME_FORM, @id, @form)
      end
      bitmap ||= load_front(hue, FEMALE_NAME, @id) if @gender == 2
      bitmap ||= load_front(hue, MALE_NAME, @id)
      return bitmap || RPG::Cache.poke_front('000')
    end
    alias battler_front battler_face

    # Return the back battle of the Pokemon
    # @return [Bitmap]
    def battler_back
      return (load_back(0, EGG_NAME_ID, @id) || RPG::Cache.poke_back(EGG_NAME)) if @step_remaining > 0
      hue = @shiny ? 1 : 0
      if @form > 0
        bitmap = load_back(hue, FEMALE_NAME_FORM, @id, @form) if @gender == 2
        bitmap ||= load_back(hue, MALE_NAME_FORM, @id, @form)
      end
      bitmap ||= load_back(hue, FEMALE_NAME, @id) if @gender == 2
      bitmap ||= load_back(hue, MALE_NAME, @id)
      return bitmap || RPG::Cache.poke_front('000')
    end

    # Return the GifReader face of the Pokemon
    # @return [::Yuki::GifReader, nil]
    def gif_face
      if @step_remaining>0
        return nil
      end
      hue = @shiny ? "Shiny" : ""
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
      hue = @shiny ? "Shiny" : ""
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

    # Return the character name of the Pokemon
    # @return [String]
    def character_name
      unless @character
        character = nil
        if(@gender==2)
          character = sprintf("%03df%s_%d",@id,@shiny ? "s" : nil,@form)
          character = nil unless RPG::Cache.character_exist?(character)
        end
        unless character
          character = sprintf("%03d%s_%d",@id,@shiny ? "s" : nil,@form)
          unless RPG::Cache.character_exist?(character)
            character = sprintf("%03d%s_0",@id,@shiny ? "s" : nil)
            character = sprintf("%03d_0",@id) unless RPG::Cache.character_exist?(character)
          end
        end
        @character = character
      end
      return @character
    end

    # Return the front offset y of the Pokemon
    # @return [Integer]
    def front_offset_y
      return GameData::Pokemon.front_offset_y(@id, @form)
    end

    private

    # Try to load an icon
    # @param args [Array] the format command parameters
    # @return [Bitmap, nil]
    def load_icon(*args)
      name = format(*args)
      return RPG::Cache.b_icon(name) if RPG::Cache.b_icon_exist?(name)
      return nil
    end

    # Try to load a front
    # @param hue [Integer] the hue asked
    # @param args [Array] the format command parameters
    # @return [Bitmap, nil]
    def load_front(hue, *args)
      name = format(*args)
      return RPG::Cache.poke_front(name, hue) if RPG::Cache.poke_front_exist?(name, hue)
      return nil
    end

    # Try to load a back
    # @param hue [Integer] the hue asked
    # @param args [Array] the format command parameters
    # @return [Bitmap, nil]
    def load_back(hue, *args)
      name = format(*args)
      return RPG::Cache.poke_back(name, hue) if RPG::Cache.poke_back_exist?(name, hue)
      return nil
    end
  end
end
