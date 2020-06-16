module UI
  # Sprite that show the 1st type of the Pokemon
  class Type1Sprite < SpriteSheet
    # Create a new Type Sprite
    # @param viewport [LiteRGSS::Viewport, nil] the viewport in which the sprite is stored
    # @param from_pokedex [Boolean] if the type is the Pokedex type (other source image)
    def initialize(viewport, from_pokedex = false)
      super(viewport, 1, GameData::Type.all.size)
      filename = "types_#{$options.language}"
      if from_pokedex
        set_bitmap(RPG::Cache.pokedex_exist?(filename) ? filename : 'types', :pokedex)
      else
        set_bitmap(RPG::Cache.interface_exist?(filename) ? filename : 'types', :interface)
      end
    end

    # Set the Pokemon used to show the type
    # @param pokemon [PFM::Pokemon, nil]
    def data=(pokemon)
      self.sy = pokemon.send(*data_source) if (self.visible = (pokemon ? true : false))
    end

    private

    # Retrieve the data source of the type sprite
    # @return [Symbol]
    def data_source
      :type1
    end
  end

  # Sprite that show the 2nd type of the Pokemon
  class Type2Sprite < Type1Sprite
    private

    # Retrieve the data source of the type sprite
    # @return [Symbol]
    def data_source
      :type2
    end
  end

  # Class that show a type image using an object that responds to #type
  class TypeSprite < Type1Sprite
    private

    # Retrieve the data source of the type sprite
    # @return [Symbol]
    def data_source
      :type
    end
  end

  # Sprite that show the gender of a Pokemon
  class GenderSprite < SpriteSheet
    # Name of the gender image in Graphics/Interface
    IMAGE_NAME = 'battlebar_gender'
    # Create a new Gender Sprite
    # @param viewport [LiteRGSS::Viewport, nil] the viewport in which the sprite is stored
    def initialize(viewport)
      super(viewport, 3, 1)
      set_bitmap(IMAGE_NAME, :interface)
    end

    # Set the Pokemon used to show the gender
    # @param pokemon [PFM::Pokemon, nil]
    def data=(pokemon)
      self.sx = pokemon.gender if (self.visible = (pokemon ? true : false))
    end
  end

  # Sprite that show the status of a Pokemon
  class StatusSprite < SpriteSheet
    # Name of the image in Graphics/Interface
    IMAGE_NAME = 'statuts'
    # Name of the image in Graphics/Interface
    IMAGE_NAME_DEFAULT = 'statutsen'
    # Number of official states
    STATE_COUNT = 10
    # Create a new Status Sprite
    # @param viewport [LiteRGSS::Viewport, nil] the viewport in which the sprite is stored
    def initialize(viewport)
      super(viewport, 1, STATE_COUNT)
      filename = IMAGE_NAME + $options.language
      filename = IMAGE_NAME_DEFAULT unless RPG::Cache.interface_exist?(filename)
      set_bitmap(filename, :interface)
    end

    # Set the Pokemon used to show the status
    # @param pokemon [PFM::Pokemon, nil]
    def data=(pokemon)
      self.sy = pokemon.status if (self.visible = (pokemon ? true : false))
    end
  end

  # Sprite that show the hold item if the pokemon is holding an item
  class HoldSprite < Sprite
    # Name of the image in Graphics/Interface
    IMAGE_NAME = 'hold'
    # Create a new Hold Sprite
    # @param viewport [LiteRGSS::Viewport, nil] the viewport in which the sprite is stored
    def initialize(viewport)
      super(viewport)
      set_bitmap(IMAGE_NAME, :interface)
    end

    # Set the Pokemon used to show the hold image
    # @param pokemon [PFM::Pokemon, nil]
    def data=(pokemon)
      self.visible = (pokemon ? pokemon.item_holding != 0 : false)
    end
  end

  # Sprite that show the actual item held if the Pokemon is holding one
  class RealHoldSprite < Sprite
    # Set the Pokemon used to show the hold image
    # @param pokemon [PFM::Pokemon, nil]
    def data=(pokemon)
      self.visible = (pokemon ? pokemon.item_holding != 0 : false)
      set_bitmap(GameData::Item[pokemon.item_holding].icon, :icon) if visible
    end
  end

  # Class that show the category of a skill
  class CategorySprite < SpriteSheet
    # Name of the image in Graphics/Interface
    IMAGE_NAME = 'skill_categories'
    # Create a new category sprite
    # @param viewport [LiteRGSS::Viewport] viewport in which the sprite is shown
    def initialize(viewport)
      super(viewport, 1, 3)
      set_bitmap(IMAGE_NAME, :interface)
    end

    # Set the object that responds to #atk_class
    # @param object [#atk_class, nil]
    def data=(object)
      self.sy = object.atk_class - 1 if (self.visible = (object ? true : false))
    end
  end

  # Class that show the face sprite of a Pokemon
  class PokemonFaceSprite < Sprite
    # Create a new Pokemon FaceSprite
    # @param viewport [Viewport] Viewport in which the sprite is shown
    # @param auto_align [Boolean] if the sprite auto align itself (sets its own ox/oy when data= is called)
    def initialize(viewport, auto_align = true)
      super(viewport)
      @auto_align = auto_align
      # @type [Yuki::GifReader]
      @gif_reader = nil
    end

    # Set the pokemon
    # @param pokemon [PFM::Pokemon, nil]
    def data=(pokemon)
      if (self.visible = (pokemon ? true : false))
        bmp = self.bitmap = load_bitmap(pokemon)
        auto_align(bmp, pokemon) if @auto_align
      end
    end

    # Update the face sprite
    def update
      @gif_reader&.update(bitmap)
    end

    private

    # Load the Sprite bitmap
    # @param pokemon [PFM::Pokemon]
    # @return [Bitmap]
    def load_bitmap(pokemon)
      bitmap&.dispose if @gif_reader
      if (@gif_reader = pokemon.send(*gif_source))
        bmp = Bitmap.new(@gif_reader.width, @gif_reader.height)
        @gif_reader.update(bmp)
        return bmp
      end
      return pokemon.send(*bitmap_source)
    end

    # Retrieve the bitmap source
    # @return [Symbol]
    def bitmap_source
      :battler_face
    end

    # Retreive the gif source
    # @return [Symbol]
    def gif_source
      :gif_face
    end

    # Align the sprite according to the bitmap properties
    # @param bmp [Bitmap] the bitmap source
    # @param pokemon [PFM::Pokemon]
    def auto_align(bmp, pokemon)
      oy = bmp.height + (self.class == PokemonFaceSprite ? pokemon.front_offset_y : 0)
      set_origin(bmp.width / 2, oy)
    end
  end

  # Class that show the back sprite of a Pokemon
  class PokemonBackSprite < PokemonFaceSprite
    private

    # Retrieve the bitmap source
    # @return [Symbol]
    def bitmap_source
      :battler_back
    end

    # Retreive the gif source
    # @return [Symbol]
    def gif_source
      :gif_back
    end
  end

  # Class that show the icon sprite of a Pokemon
  class PokemonIconSprite < SpriteSheet
    # Create a new Pokemon FaceSprite
    # @param viewport [Viewport] Viewport in which the sprite is shown
    # @param auto_align [Boolean] if the sprite auto align itself (sets its own ox/oy when data= is called)
    def initialize(viewport, auto_align = true)
      super(viewport, 2, 1)
      @auto_align = auto_align
      @max_counter = 60
      @counter = 0
    end

    # Set the pokemon
    # @param pokemon [PFM::Pokemon, nil]
    def data=(pokemon)
      if (self.visible = (pokemon ? true : false))
        bmp = pokemon.icon
        @nb_x = (bmp.width / bmp.height).clamp(1, Float::INFINITY)
        self.bitmap = bmp
        auto_align(bmp) if @auto_align
        @counter = 0
        @max_counter = max_counter(pokemon)
      end
    end

    # Update the pokemon animation
    def update
      @counter += 1
      if @counter >= @max_counter
        self.sx = (@sx + 1) % 2
        @counter = 0
      end
    end

    private

    # Find the max number of frame before switching the @sx value
    # @param pokemon [PFM::Pokemon, nil]
    def max_counter(pokemon)
      return Float::INFINITY if pokemon.asleep? || pokemon.dead?
      # Changes speed for Pokemon with status effects
      return 20 + ((1 - pokemon.hp_rate) * 120).to_i if pokemon.status != 0
      # Changes speed for Pokemon
      return 10 + ((1 - pokemon.hp_rate) * 60).to_i
    end

    # Align the sprite according to the bitmap properties
    # @param bmp [Bitmap] the bitmap source
    def auto_align(bmp)
      set_origin(width / 2, bmp.height / 2)
    end
  end

  # Class that show the icon sprite of a Pokemon
  class PokemonFootSprite < Sprite
    # Format of the icon name
    D3 = '%03d'
    # Set the pokemon
    # @param pokemon [PFM::Pokemon, nil]
    def data=(pokemon)
      self.bitmap = RPG::Cache.foot_print(format(D3, pokemon.id)) if (self.visible = (pokemon ? true : false))
    end
  end

  # Class that show the item icon
  class ItemSprite < Sprite
    # Set the item that should be shown
    # @param item_id [Integer, Symbol]
    def data=(item_id)
      set_bitmap(GameData::Item[item_id].icon, :icon)
    end
  end

  # Class that show the category of a skill
  class AttackDummySprite < SpriteSheet
    # Name of the image shown
    IMAGE_NAME = 'battle_attack_dummy'
    # Create a new category sprite
    # @param viewport [LiteRGSS::Viewport] viewport in which the sprite is shown
    def initialize(viewport)
      super(viewport, 1, GameData::Type.all.size)
      set_bitmap(IMAGE_NAME, :interface)
    end

    # Set the object that responds to #atk_class
    # @param object [#atk_class, nil]
    def data=(object)
      self.sy = object.type if (self.visible = (object ? true : false))
    end
  end

  # Object that show a text using a method of the data object sent
  class SymText < Text
    # Add a text inside the window, the offset x/y will be adjusted
    # @param font_id [Integer] the id of the font to use to draw the text
    # @param viewport [LiteRGSS::Viewport, nil] the viewport used to show the text
    # @param x [Integer] the x coordinate of the text surface
    # @param y [Integer] the y coordinate of the text surface
    # @param width [Integer] the width of the text surface
    # @param height [Integer] the height of the text surface
    # @param method [Symbol] the symbol of the method to call in the data object
    # @param align [0, 1, 2] the align of the text in its surface (best effort => no resize), 0 = left, 1 = center, 2 = right
    # @param outlinesize [Integer, nil] the size of the text outline
    # @param color [Integer] the id of the color
    # @param sizeid [Intger] the id of the size to use
    def initialize(font_id, viewport, x, y, width, height, method, align = 0, outlinesize = nil, color = nil, sizeid = nil)
      super(font_id, viewport, x, y, width, height, nil.to_s, align, outlinesize, color, sizeid)
      @method = method
    end

    # Set the Object used to show the text
    # @param object [Object, nil]
    def data=(object)
      return unless (self.visible = (object ? true : false))
      self.text = object.public_send(@method).to_s
    end
  end

  # Object that show a multiline text using a method of the data object sent
  class SymMultilineText < SymText
    # Set the Object used to show the text
    # @param object [Object, nil]
    def data=(object)
      return unless (self.visible = (object ? true : false))
      self.multiline_text = object.public_send(@method).to_s
    end
  end
end
