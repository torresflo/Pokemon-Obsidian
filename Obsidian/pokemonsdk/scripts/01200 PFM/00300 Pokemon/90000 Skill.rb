module PFM
  # The InGame skill/move information of a Pokemon
  # @author Nuri Yuri
  class Skill
    # The maximum number of PP the skill has
    # @return [Integer]
    attr_accessor :ppmax
    # The current number of PP the skill has
    # @return [Integer]
    attr_reader :pp
    # If the move has been used
    # @return [Boolean]
    attr_accessor :used
    # The alternative Power information of the skill (dynamic power)
    # @return [Integer, nil]
    attr_accessor :power2
    # The alternatif type information of the skill (dynamic type)
    # @return [Integer, nil] ID of the type
    attr_accessor :type2
    # The alternative accuracy information of the skill (dynamic accuracy)
    # @return [Integer, nil]
    attr_accessor :accuracy2
    # ID of the skill in the Database
    # @return [Integer]
    attr_reader :id
    # Create a new Skill information
    # @param id [Integer] ID of the skill/move in the database
    def initialize(id)
      data = GameData::Skill[id]
      @id = data.id
      if @id == 0
        @ppmax = 0
        @pp = 0
        return
      end
      @ppmax = data.pp_max
      @pp = @ppmax
      @used = false
      # Ivar used when move is changed to another move
      @id_bis = id
      @pp_max_bis = nil
      @pp_bis = nil
      # Ivar used when battle change the move info (dynamic power/type/acc)
      @power2 = nil
      @type2 = nil
      @accuracy2 = nil
    end

    # Return the actual data of the move
    # @return [GameData::Skill]
    def data
      return GameData::Skill[@id || 0]
    end

    # Reset the skill/move information
    def reset
      @id = @id_bis
      @pp = @pp_bis if @pp_bis
      @ppmax = @pp_max_bis if @pp_max_bis
      @used = false
      @pp_bis = nil
      @pp_max_bis = nil
      @power2 = nil
      @type2 = nil
      @accuracy2 = nil
    end

    # Change the skill information (copy, sketch, Z-move etc...)
    # @param id [Integer] ID of the skill in the database
    # @param pp [Integer, nil] the number of pp of the skill, nil = no change about PPs
    # @param sketch [Boolean] if the skill informations are definitely changed
    def switch(id, pp = 10, sketch = false)
      return initialize(id) if sketch

      data = GameData::Skill[id]
      @id_bis = @id
      @pp_bis = @pp if pp
      @pp_max_bis = @ppmax
      @id = data.id
      if @id == 0
        @pp = @ppmax = 0
        return
      end

      if pp
        pp = data.pp_max if data.pp_max < pp
        @pp = pp
        @ppmax = pp
      end
      @used = false
    end

    # Return the db_symbol of the skill
    # @return [Symbol]
    def db_symbol
      return data.db_symbol
    end

    # Return the name of the skill
    # @return [String]
    def name
      return data.name
    end

    # Return the symbol of the method to call in BattleEngine
    # @return [Symbol]
    def symbol
      return data.be_method
    end

    # Return the actual power of the skill
    # @return [Integer]
    def power
      return @power2 || base_power
    end

    # Return the text of the power of the skill
    # @return [String]
    def power_text
      power = base_power
      return text_get(11, 12) if power == 0

      return power.to_s
    end

    # Return the text of the PP of the skill
    # @return [String]
    def pp_text
      "#{@pp} / #{@ppmax}"
    end

    # Return the base power (Data power) of the skill
    # @return [Integer]
    def base_power
      return data.power
    end

    # Return the actual type ID of the skill
    # @return [Integer]
    def type
      return @type2 || data.type
    end

    # Return the actual accuracy of the skill
    # @return [Integer]
    def accuracy
      return @accuracy2 || data.accuracy
    end

    # Return the accuracy text of the skill
    # @return [String]
    def accuracy_text
      acc = data.accuracy
      return text_get(11, 12) if acc == 0

      return acc.to_s
    end

    # Return the chance of effect of the skill
    # @return [Integer]
    def effect_chance
      return data.effect_chance
    end

    # Return the status effect the skill can inflict
    # @return [Integer, nil]
    def status_effect
      return data.status
    end

    # Return the stat tage modifier the skill can apply
    # @return [Array<Integer>]
    def battle_stage_mod
      return data.battle_stage_mod
    end

    # Return the target symbol the skill can aim
    # @return [Symbol]
    def target
      return data.target
    end

    # Is the skill affected by gravity
    # @return [Boolean]
    def gravity_affected?
      return data.gravity
    end

    # Return the skill description
    # @return [String]
    def description
      return text_get(7, @id || 0) # GameData::Skill.descr(@id)
    end

    # Is the skill direct ?
    # @return [Boolean]
    def direct?
      return data.direct
    end

    # Is the skill affected by Mirror Move
    # @return [Boolean]
    def mirror_move?
      return data.mirror_move
    end

    # Return the priority of the skill
    # @return [Integer]
    def priority
      return data.priority
    end

    # Return the ID of the common event to call on Map use
    # @return [Integer]
    def map_use
      return data.map_use
    end

    # Is the skill blocable by Protect and skill like that ?
    # @return [Boolean]
    def blocable?
      return data.blocable
    end

    # Is the skill physical ?
    # @return [Boolean]
    def physical?
      return data.atk_class == 1
    end

    # Is the skill special ?
    # @return [Boolean]
    def special?
      return data.atk_class == 2
    end

    # Is the skill status ?
    # @return [Boolean]
    def status?
      return data.atk_class == 3
    end

    # Return the class of the skill
    # @return [Integer] 1, 2, 3
    def atk_class
      return data.atk_class
    end

    # Is the skill a specific type ?
    # @param type_id [Integer] ID of the type
    def type?(type_id)
      return type == type_id
    end

    # Is the skill type normal ?
    # @return [Boolean]
    def type_normal?
      return type?(GameData::Types::NORMAL)
    end

    # Is the skill type fire ?
    # @return [Boolean]
    def type_fire?
      return type?(GameData::Types::FIRE)
    end
    alias type_feu? type_fire?

    # Is the skill type water ?
    # @return [Boolean]
    def type_water?
      return type?(GameData::Types::WATER)
    end
    alias type_eau? type_water?

    # Is the skill type electric ?
    # @return [Boolean]
    def type_electric?
      return type?(GameData::Types::ELECTRIC)
    end
    alias type_electrique? type_electric?

    # Is the skill type grass ?
    # @return [Boolean]
    def type_grass?
      return type?(GameData::Types::GRASS)
    end
    alias type_plante? type_grass?

    # Is the skill type ice ?
    # @return [Boolean]
    def type_ice?
      return type?(GameData::Types::ICE)
    end
    alias type_glace? type_ice?

    # Is the skill type fighting ?
    # @return [Boolean]
    def type_fighting?
      return type?(GameData::Types::FIGHTING)
    end
    alias type_combat? type_fighting?

    # Is the skill type poison ?
    # @return [Boolean]
    def type_poison?
      return type?(GameData::Types::POISON)
    end

    # Is the skill type ground ?
    # @return [Boolean]
    def type_ground?
      return type?(GameData::Types::GROUND)
    end
    alias type_sol? type_ground?

    # Is the skill type fly ?
    # @return [Boolean]
    def type_flying?
      return type?(GameData::Types::FLYING)
    end
    alias type_vol? type_flying?
    alias type_fly? type_flying?

    # Is the skill type psy ?
    # @return [Boolean]
    def type_psychic?
      return type?(GameData::Types::PSYCHIC)
    end
    alias type_psy? type_psychic?

    # Is the skill type insect/bug ?
    # @return [Boolean]
    def type_insect?
      return type?(GameData::Types::BUG)
    end

    # Is the skill type rock ?
    # @return [Boolean]
    def type_rock?
      return type?(GameData::Types::ROCK)
    end
    alias type_roche? type_rock?

    # Is the skill type ghost ?
    # @return [Boolean]
    def type_ghost?
      return type?(GameData::Types::GHOST)
    end
    alias type_spectre? type_ghost?

    # Is the skill type dragon ?
    # @return [Boolean]
    def type_dragon?
      return type?(GameData::Types::DRAGON)
    end

    # Is the skill type steel ?
    # @return [Boolean]
    def type_steel?
      return type?(GameData::Types::STEEL)
    end
    alias type_acier? type_steel?

    # Is the skill type dark ?
    # @return [Boolean]
    def type_dark?
      return type?(GameData::Types::DARK)
    end
    alias type_tenebre? type_dark?

    # Is the skill type fairy ?
    # @return [Boolean]
    def type_fairy?
      return type?(GameData::Types::FAIRY)
    end
    alias type_fee? type_fairy?

    # Does the skill has recoil ?
    # @return [Boolean]
    def recoil?
      return symbol == :s_recoil
    end

    # Is the skill a punching move ?
    # @return [Boolean]
    def punching?
      return data.punching?
    end

    # Return the critical rate of the skill
    # @return [Integer]
    def critical_rate
      return data.critical_rate
    end

    # Is the skill a sound attack ?
    # @return [Boolean]
    def sound_attack?
      return data.sound_attack
    end

    # Does the skill unfreeze
    # @return [Boolean]
    def unfreeze?
      return data.unfreeze
    end

    # Does the skill trigger the king rock
    # @return [Boolean]
    def king_rock_utility
      return status_effect != 7 # Flinch
    end

    # Is the skill snatchable ?
    # @return [Boolean]
    def snatchable
      return data.snatchable
    end

    # Is the skill affected by magic coat ?
    # @return [Boolean]
    def magic_coat_affected
      return data.magic_coat_affected
    end

    # Change the PP
    # @param v [Integer] the new pp value
    def pp=(v)
      @pp = v
      @pp = @ppmax if @pp > @ppmax
      @pp = 0 if @pp < 0
    end

    # Convert skill to string
    # @return [String]
    def to_s
      return "<S:#{name}_#{power}_#{accuracy}>"
    end

    # List of symbol describe a one target aim
    OneTarget = [:any_other_pokemon, :random_foe, :adjacent_pokemon, :adjacent_foe, :user, :user_or_adjacent_ally, :adjacent_ally]
    # Does the skill aim only one Pokemon
    # @return [Boolean]
    def is_one_target?
      return OneTarget.include?(target)
    end

    # List of symbol that doesn't show any choice of target
    TargetNoAsk = [:adjacent_all_foe, :all_foe, :adjacent_all_pokemon, :all_pokemon, :user, :all_ally, :random_foe]
    # Does the skill doesn't show a target choice
    # @return [Boolean]
    def is_no_choice_skill?
      return TargetNoAsk.include?(target)
    end
  end
end
