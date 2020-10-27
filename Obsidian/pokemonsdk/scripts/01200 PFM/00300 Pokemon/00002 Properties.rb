module PFM
  class Pokemon
    # ID of the Pokemon in the database
    # @return [Integer]
    attr_reader :id
    # Current Level of the Pokemon
    # @return [Integer]
    attr_reader :level
    # The total amount of exp the Pokemon got
    # @return [Integer]
    attr_accessor :exp
    # The current HP the Pokemon has
    # @return [Integer]
    attr_reader :hp
    # Code of the pokemon
    # @return [Integer]
    attr_accessor :code
    # Number of step before the egg hatch (thus the Pokemon is an egg)
    # @return [Integer]
    attr_accessor :step_remaining
    # ID of the item used to catch the Pokemon
    # @return [Integer]
    attr_accessor :captured_with
    # Zone (id) where the Pokemon was captured mixed with the Gemme 4.0 Flag
    # @return [Integer]
    attr_accessor :captured_in
    # Time when the Pokemon was captured (in seconds from jan 1970)
    # @return [Integer]
    attr_accessor :captured_at
    # Level of the Pokemon when the Pokemon was caught
    # @return [Integer]
    attr_accessor :captured_level
    # Zone (id) where the Egg has been obtained
    # @return [Integer]
    attr_accessor :egg_in
    # Time when the Egg has been obtained
    # @return [Integer]
    attr_accessor :egg_at
    # ID of the original trainer
    # @return [Integer]
    attr_writer :trainer_id
    # Name of the original trainer
    # @return [String]
    attr_accessor :trainer_name
    # The name given to the Pokemon
    # @return [String]
    attr_accessor :given_name
    # Gender of the Pokemon : 0 = no gender, 1 = male, 2 = female
    # @return [Integer]
    attr_reader :gender
    # Happiness/loyalty of the Pokemon (0 no bonds, 255 full bonds)
    # @return [Integer]
    attr_reader :loyalty
    # Form Index of the Pokemon, ex: Unkown A = 0, Unkown Z = 25
    # @return [Integer]
    attr_reader :form
    # HP Effort Value
    # @return [Integer]
    attr_accessor :ev_hp
    # ATK Effort Value
    # @return [Integer]
    attr_accessor :ev_atk
    # DFE Effort Value
    # @return [Integer]
    attr_accessor :ev_dfe
    # SPD Effort Value
    # @return [Integer]
    attr_accessor :ev_spd
    # ATS Effort Value
    # @return [Integer]
    attr_accessor :ev_ats
    # DFS Effort Value
    # @return [Integer]
    attr_accessor :ev_dfs
    # HP Individual Value
    # @return [Integer]
    attr_accessor :iv_hp
    # ATK Individual Value
    # @return [Integer]
    attr_accessor :iv_atk
    # DFE Individual Value
    # @return [Integer]
    attr_accessor :iv_dfe
    # SPD Individual Value
    # @return [Integer]
    attr_accessor :iv_spd
    # ATS Individual Value
    # @return [Integer]
    attr_accessor :iv_ats
    # DFS Individual Value
    # @return [Integer]
    attr_accessor :iv_dfs
    # ID of the Pokemon's nature (in the database)
    # @return [Integer]
    attr_writer :nature
    # The rate of HP the Pokemon has
    # @return [Float]
    attr_accessor :hp_rate
    # The rate of exp point the Pokemon has in its level
    # @return [Float]
    attr_accessor :exp_rate
    # ID of the item the Pokemon is holding
    # @return [Integer]
    attr_accessor :item_holding
    # First type ID of the Pokemon
    # @return [Integer]
    attr_writer :type1
    # Second type ID of the Pokemon
    # @return [Integer]
    attr_writer :type2
    # Third type ID of the Pokemon (moves/Mega)
    # @return [Integer]
    attr_writer :type3
    # Character filename of the Pokemon (FollowMe optimizations)
    # @return [String]
    attr_accessor :character
    # Memo text [file_id, text_id]
    # @return [Array<Integer>]
    attr_accessor :memo_text
    # List of Ribbon ID the Pokemon got
    # @return [Array<Integer>]
    attr_accessor :ribbons
    # List of Skill id the Pokemon learnt during its life
    # @return [Array<Integer>]
    attr_reader :skill_learnt
    # The current moveset of the Pokemon
    # @return [Array<PFM::Skill>] 4 or less moves
    attr_accessor :skills_set
    # If the Truant (Absenteisme) ability has been "used"
    # @return [Boolean]
    attr_accessor :ability_used
    # ID of the Pokemon ability in the database
    # @return [Integer]
    attr_writer :ability
    # ID of the ability the Pokemon has in battle
    # @return [Integer]
    attr_accessor :ability_current
    # Index of the ability in the Pokemon data
    # @return [Integer, nil]
    attr_accessor :ability_index
    # ID of the status of the Pokemon
    # @return [Integer]
    attr_accessor :status
    # Internal status counter that helps some status to terminate or worsen
    # @return [Integer]
    attr_accessor :status_count

    # ========================
    # Battle Related Modifier
    # ========================

    # The battle Stage of the Pokemon [atk, dfe, spd, ats, dfs, eva, acc]
    # @return [Array(Integer, Integer, Integer, Integer, Integer, Integer, Integer)]
    attr_accessor :battle_stage
    # The Pokemon critical modifier (always 0 but usable for scenaristic reasons...)
    # @return [Integer]
    attr_accessor :critical_modifier
    # Last skill ID used in battle
    # @return [Integer]
    attr_accessor :last_skill
    # Number of times the last skill was used
    # @return [Integer]
    attr_accessor :skill_use_times
    # The position in the Battle, > 0 = actor, < 0 = enemy (index = -position-1), nil = not fighting
    # @return [Integer, nil]
    attr_accessor :position
    # The effect data information...
    # @return [Pokemon_Effect, nil]
    attr_accessor :battle_effect
    # If the pokemon is confused
    # @return [Boolean]
    attr_accessor :confuse
    # Number of turn the Pokemon has fought
    # @return [Integer]
    attr_accessor :battle_turns
    # Attack order value tells when the Pokemon attacks (used to test if attack before another pokemon)
    # @return [Integer]
    attr_accessor :attack_order
    # ID of the skill the Pokemon would like to use
    # @return [Integer]
    attr_accessor :prepared_skill
    # Real id of the Pokemon when used transform
    # @return [Integer, nil]
    attr_accessor :sub_id
    # Real code of the Pokemon when used transform (needed to test if roaming pokemon is ditto)
    # @return [Integer, nil]
    attr_accessor :sub_code
    # Real form index of the Pokemon when used transform (needed to test if roaming pokemon is ditto)
    # @return [Integer, nil]
    attr_accessor :sub_form
    # ID of the item the Pokemon is holding in battle
    # @return [Integer, nil]
    attr_accessor :battle_item
    # Various data information of the item during battle
    # @return [Array, nil]
    attr_accessor :battle_item_data

    # Get the primary data of the Pokemon
    # @return [GameData::Pokemon]
    def primary_data
      GameData::Pokemon[id, 0]
    end

    # Get the current data of the Pokemon
    def data
      GameData::Pokemon[id, form || 0]
    end
    alias get_data data

    # Give the maximum level of the Pokemon
    # @return [Integer]
    def max_level
      infinity = Float::INFINITY
      return [@max_level || infinity, $pokemon_party.level_max_limit || infinity, PSDK_CONFIG.pokemon_max_level].min
    end

    # Set the maximum level of the Pokemon
    # @param level [Integer, nil]
    def max_level=(level)
      @max_level = level.is_a?(Integer) ? level : nil
    end

    # Get the shiny attribute
    # @return [Boolean]
    def shiny?
      return (@code & 0xFFFF) < shiny_rate || @shiny
    end
    alias shiny shiny?

    # Set the shiny attribut
    # @param shiny [Boolean]
    def shiny=(shiny)
      @code = (@code & 0xFFFF0000) | (shiny ? 0 : 0xFFFF)
    end

    # Give the shiny rate for the Pokemon, The number should be between 0 & 0xFFFF.
    # 0 means absolutely no chance to be shiny, 0xFFFF means always shiny
    # @return [Integer]
    def shiny_rate
      16
    end

    # Return the db_symbol of the Pokemon in the database
    # @return [Symbol]
    def db_symbol
      GameData::Pokemon.db_symbol(id)
    end

    # Tell if the Pokemon is an egg or not
    # @return [Boolean]
    def egg?
      return @step_remaining > 0
    end
    alias egg egg?

    # Set the captured_in flags (to know from which game the pokemon came from)
    # @param flag [Integer] the new flag
    def flags=(flag)
      @captured_in = zone_id | (flag & 0xFFFF_0000)
    end

    # Get Pokemon flags
    # @return [Integer]
    def flags
      return @captured_in & 0xFFFF_0000
    end

    # Tell if the pokemon is from a past version
    # @return [Boolean]
    def from_past?
      return !flags.anybits?(FLAG_PRESENT_TIME)
    end

    # Tell if the Pokemon is caught by the trainer
    # @return [Boolean]
    def caught_by_player?
      return flags.anybits?(FLAG_CAUGHT_BY_PLAYER)
    end

    # Get the zone id where the Pokemon has been found
    # @param special_zone [Integer, nil] if you want to use this function for stuff like egg_zone_id
    def zone_id(special_zone = nil)
      (special_zone || @captured_in) & 0x0000FFFF
    end

    # Set the gender of the Pokemon
    # @param gender [Integer]
    def gender=(gender)
      if primary_data.female_rate == -1
        @gender = 0
      elsif primary_data.female_rate == 0
        @gender = 1
      elsif primary_data.female_rate == 100
        @gender = 2
      else
        gender = %w[i m f].index(gender.downcase).to_i if gender.is_a?(String)
        @gender = gender.clamp(0, 2)
      end
    end
    alias set_gender gender=

    # Tell if the Pokemon is genderless
    # @return [Boolean]
    def genderless?
      gender == 0
    end

    # Tell if the Pokemon is a male
    # @return [Boolean]
    def male?
      gender == 1
    end

    # Tell if the Pokemon is a female
    # @return [Boolean]
    def female?
      gender == 2
    end

    # Change the Pokemon Loyalty
    # @param loyalty [Integer] new loyalty value
    def loyalty=(loyalty)
      @loyalty = loyalty.clamp(0, 255)
    end

    # Return the nature data of the Pokemon
    # @return [Array<Integer>] [text_id, atk%, dfe%, spd%, ats%, dfs%]
    def nature
      return GameData::Natures[@nature]
    end

    # Return the nature id of the Pokemon
    # @return [Integer]
    def nature_id
      return @nature
    end

    # Return the Pokemon rareness
    # @return [Integer]
    def rareness
      return @rareness || data.rareness
    end

    # Change the Pokemon rareness
    # @param v [Integer, nil] the new rareness of the Pokemon
    def rareness=(v)
      @rareness = v&.clamp(0, 255)
    end

    # Return the breed groups of the Pokemon
    # @return [Array(Integer, Integer)]
    def breed_group
      return data.breed_groupes
    end

    # Return the breed moves of the Pokemon (list of skill ID)
    # @return [Array<Integer>]
    def breed_move
      return data.breed_moves
    end

    # Return the height of the Pokemon
    # @return [Numeric]
    def height
      return data.height
    end

    # Return the weight of the Pokemon
    # @return [Numeric]
    def weight
      return data.weight
    end

    # Return the ball sprite name of the Pokemon
    # @return [String] Sprite to load in Graphics/ball/
    def ball_sprite
      return GameData::Item[@captured_with].ball_data&.img || 'ball_1'
    end

    # Return the ball color of the Pokemon (flash)
    # @return [Color]
    def ball_color
      return GameData::Item[@captured_with].ball_data&.color || Color.new(0, 0, 0)
    end

    # Return the normalized trainer id of the Pokemon
    # @return [Integer]
    def trainer_id
      return @trainer_id % 100_000
    end

    # Return if the Pokemon is from the player (he caught it)
    # @return [Boolean]
    def from_player?
      return flags.anybits?(FLAG_CAUGHT_BY_PLAYER)
    end

    # Return the db_symbol of the Pokemon's item held
    # @return [Symbol]
    def item_db_symbol
      return GameData::Item.db_symbol($game_temp.in_battle ? (@battle_item || @item_holding) : @item_holding)
    end

    # Alias for item_holding
    # @return [Integer]
    def item_hold
      return @item_holding
    end

    # Return the current ability of the Pokemon
    # @return [Integer]
    def ability
      return @ability_current
    end

    # Return the db_symbol of the Pokemon's Ability
    # @return [Symbol]
    def ability_db_symbol
      GameData::Abilities.db_symbol(ability)
    end

    # Add a ribbon to the Pokemon
    # @param id [Integer] ID of the ribbon (in the ribbon text file)
    def add_ribbon(id)
      return unless id.between?(0, 50)

      @ribbons << id unless @ribbons.include?(id)
    end

    # Has the pokemon got a ribbon ?
    # @return [Boolean]
    def ribbon_got?(id)
      return @ribbons.include?(id)
    end
  end
end
