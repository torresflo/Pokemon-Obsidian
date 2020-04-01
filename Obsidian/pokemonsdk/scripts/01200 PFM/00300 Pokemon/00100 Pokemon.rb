module PFM
  # The InGame Pokemon management
  # @author Nuri Yuri
  class Pokemon
    # Flag in captured_in that tells the Pokemon was from Pokemon Gemme 3.9
    Flag_39 = 0x00FE0000
    # Flag in captured_in that tells the Pokemon was from Pokemon Gemme 4.0+
    Flag_40 = 0x00EF0000
    # Flag that tells the Pokemon object to generate Shiny with IV starting at 15
    Shiny_IV = false
    # ID of the Pokemon in the database
    # @return [Integer]
    attr_accessor :id
    # The name given to the Pokemon
    # @return [String]
    attr_accessor :given_name
    # The secret code of the Pokemon
    # @return [Integer]
    attr_accessor :code
    # ID of the Pokemon ability in the database
    # @return [Integer]
    attr_accessor :ability
    # If the Truant (Absentéisme) ability has been "used"
    # @return [Boolean]
    attr_accessor :ability_used
    # ID of the ability the Pokemon has in battle
    # @return [Integer]
    attr_accessor :ability_current
    # Index of the ability in the Pokemon data
    # @return [Integer, nil]
    attr_accessor :ability_index
    # ID of the Pokemon's nature (in the database)
    # @return [Integer]
    attr_accessor :nature
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
    # Number of step before the egg hatch (thus the Pokemon is an egg)
    # @return [Integer]
    attr_accessor :step_remaining
    # ID of the original trainer
    # @return [Integer]
    attr_accessor :trainer_id
    # Name of the original trainer
    # @return [String]
    attr_accessor :trainer_name
    # The total amount of exp the Pokemon got
    # @return [Integer]
    attr_accessor :exp
    # The current moveset of the Pokemon
    # @return [Array<PFM::Skill>] 4 or less moves
    attr_accessor :skills_set
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
    # The current HP the Pokemon has
    # @return [Integer]
    attr_accessor :hp
    # ID of the status of the Pokemon
    # @return [Integer]
    attr_accessor :status
    # Internal status counter that helps some status to terminate or worsen
    # @return [Integer]
    attr_accessor :status_count
    # Friendship/loyalty of the Pokemon (0 no bonds, 255 full bonds)
    # @return [Integer]
    attr_accessor :loyalty
    # The battle Stage of the Pokemon [atk, dfe, spd, ats, dfs, eva, acc]
    # @return [Array(Integer, Integer, Integer, Integer, Integer, Integer, Integer)]
    attr_accessor :battle_stage
    # The Pokemon critical modifier (always 0 but usable for scenaristic reasons...)
    # @return [Integer]
    attr_accessor :critical_modifier
    # Form Index of the Pokemon, ex: Zarbi A = 0, Zarbi Z = 25
    # @return [Integer]
    attr_accessor :form
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
    # ID of the item the Pokemon is holding
    # @return [Integer]
    attr_accessor :item_holding
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
    # If the Pokemon is shiny
    # @return [Boolean]
    attr_accessor :shiny
    # Current Level of the Pokemon
    # @return [Integer]
    attr_accessor :level
    # Gender of the Pokemon : 0 = no gender, 1 = male, 2 = female
    # @return [Integer]
    attr_accessor :gender
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
    # If shiny or not for the Pokemon when used transform (needed to test if roaming pokemon is ditto)
    # @return [Integer, nil]
    attr_accessor :sub_shiny
    # Real form index of the Pokemon when used transform (needed to test if roaming pokemon is ditto)
    # @return [Integer, nil]
    attr_accessor :sub_form
    # ID of the item the Pokemon is holding in battle
    # @return [Integer, nil]
    attr_accessor :battle_item
    # Various data information of the item during battle
    # @return [Array, nil]
    attr_accessor :battle_item_data
    # The rate of HP the Pokemon has
    # @return [Float]
    attr_accessor :hp_rate
    # The rate of exp point the Pokemon has in its level
    # @return [Float]
    attr_accessor :exp_rate
    # First type ID of the Pokemon
    # @return [Integer]
    attr_accessor :type1
    # Second type ID of the Pokemon
    # @return [Integer]
    attr_accessor :type2
    # Third type ID of the Pokemon (moves/Mega)
    # @return [Integer]
    attr_accessor :type3
    # Character filename of the Pokemon (FollowMe optimizations)
    # @return [String]
    attr_accessor :character
    # List of Skill id the Pokemon learnt during its life
    # @return [Array<Integer>]
    attr_accessor :skill_learnt
    # List of Ribbon ID the Pokemon got
    # @return [Array<Integer>]
    attr_accessor :ribbons
    # Memo text [file_id, text_id]
    # @return [Array<Integer>]
    attr_accessor :memo_text
    # Create a new Pokemon with specific parameters
    # @param id [Integer] ID of the Pokemon in the database
    # @param level [Integer] level of the Pokemon
    # @param force_shiny [Boolean] if the Pokemon have 100% chance to be shiny
    # @param no_shiny [Boolean] if the Pokemon have 0% chance to be shiny (override force_shiny)
    # @param form [Integer] Form index of the Pokemon (-1 = automatic generation)
    def initialize(id, level, force_shiny = false, no_shiny = false, form = -1)
      # >Informations utiles à la génération du code
      @captured_with = 4
      @captured_in = $env.master_zone | Flag_40
      @captured_at = Time.new.to_i
      @captured_level = level
      @trainer_id = $trainer.id
      @trainer_name = $trainer.name
      # Code generation
      code_generation(force_shiny, no_shiny)

      @id = id
      form = form_generation(form)
      data = GameData::Pokemon.all[id][form]
      form = 0 unless data
      data = GameData::Pokemon.get_data(id, form)
      @level = level.to_i
      @step_remaining = 0
      @given_name = nil
      @ev_hp = 0
      @ev_atk = 0
      @ev_dfe = 0
      @ev_spd = 0
      @ev_ats = 0
      @ev_dfs = 0
      @form = form
      @gender = gender_generation
      @status = 0
      @status_count = 0
      @battle_stage = Array.new(7, 0)
      @last_skill = 0
      @position = 0
      @battle_effect = nil
      ability = data.abilities
      # >Récupération du talent (caché ou non)
      ability_chance = rand(100)
      @ability = if ability_chance < 2
                   ability[@ability_index = 2].to_i
                 elsif ability_chance < 50
                   ability[@ability_index = 1].to_i
                 else
                   ability[@ability_index = 0].to_i
                 end
      @ability_current = @ability
      @nature = @code % GameData::Natures.size
      @loyalty = data.base_loyalty
      @exp = exp_list[@level].to_i
      # >Génération des IV
      iv_base = (Shiny_IV && @shiny ? 15 : 0)
      iv_rand = (Shiny_IV && @shiny ? 17 : 32)
      @iv_hp = Random::IV_HP.rand(iv_rand) + iv_base # rand(iv_rand) + iv_base
      @iv_atk = Random::IV_ATK.rand(iv_rand) + iv_base # rand(iv_rand) + iv_base
      @iv_dfe = Random::IV_DFE.rand(iv_rand) + iv_base # rand(iv_rand) + iv_base
      @iv_spd = Random::IV_SPD.rand(iv_rand) + iv_base # rand(iv_rand) + iv_base
      @iv_ats = Random::IV_ATS.rand(iv_rand) + iv_base # rand(iv_rand) + iv_base
      @iv_dfs = Random::IV_DFS.rand(iv_rand) + iv_base # rand(iv_rand) + iv_base
      # >Génération du Skillset
      @skill_learnt = []
      @skills_set = []
      (data.move_set.size - 2).step(0, -2) do |i|
        if data.move_set[i].between?(0, @level)
          learn_skill(data.move_set[i + 1]) unless skill_learnt?(data.move_set[i + 1])
          # @skills_set<<Skill.new(data.move_set[i+1]) unless skill_learnt?(data.move_set[i+1])
          break if @skills_set.size >= 4
        end
      end
      @skills_set.reverse!
      @hp = max_hp
      # >Selection de l'objet aléatoire
      parr = []
      iarr = []
      _per = 0
      _items = data.items
      (_items.size / 2).times do |i|
        iarr << _items[i * 2]
        _per += _items[i * 2 + 1]
        parr << _per
      end
      unless parr.empty?
        _rand = rand(100)
        parr.size.times do |i|
          if _rand < parr[i]
            @item_holding = iarr[i]
            break
          end
        end
      end
      @item_holding = @item_holding.to_i
      parr = nil
      iarr = nil
      @battle_turns = 0
      @ability_used = false
      @sub_id = nil
      @sub_shiny = nil
      @sub_form = nil
      @hp_rate = 1
      @exp_rate = 0
      @mega_evolved = false
      @memo_text = nil
    end
    # Code generation of the Pokemon (taking various informations in considerations)
    # @param force_shiny [Boolean] if the Pokemon have 100% chance to be shiny
    # @param no_shiny [Boolean] if the Pokemon have 0% chance to be shiny (override force_shiny)
    def code_generation(force_shiny = false, no_shiny = false)
      @code = (@captured_at & 0x000FFFFF) ^ (rand(0xFF01) & 0xFF00)
      @code ^= ((@trainer_id & 0x0000FFFF) << 8)
      # >Vérification du charme chroma
      shiny_chance = $bag.contain_item?(632) ? 0x0556 : 0x1000
      force_shiny ||= (rand(shiny_chance) == 0)
      @code ^= ((no_shiny ? 0x0001 : (force_shiny ? 0x1111 : rand(shiny_chance))) << 16)
      # Caractère shiny
      shiny_v = ((@code & 0xFFFF0000) ^ ((@trainer_id & 0x0000FF00) << 8))
      shiny_v ^= (@captured_at & 0x000F0000)
      @shiny = (shiny_v == 0x11110000)
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
    # Return the primitive data of the Pokemon
    # @return [GameData::Pokemon]
    def get_data
      return GameData::Pokemon.get_data(@id, @form)
    end
    # Change the gender of the Pokemon
    # @param g [Integer, String] "i", 0, "m", 1, "f", 2
    def set_gender(g)
      if g.class==String
        @gender=["i","m","f"].index(g[0,1].downcase).to_i
      else
        @gender=g if g<3 and g>=0
      end
    end
    # Return the breed groups of the Pokemon
    # @return [Array(Integer, Integer)]
    def breed_group
      return get_data.breed_groupes
    end
    # Return the breed moves of the Pokemon (list of skill ID)
    # @return [Array<Integer>]
    def breed_move
      return get_data.breed_moves
    end
    # Return the ball sprite name of the Pokemon
    # @return [String] Sprite to load in Graphics/ball/
    def ball_sprite
      ball=GameData::Item.ball_data(@captured_with)
      if(ball)
        return ball.img
      else
        return "ball_1"
      end
    end
    # @deprecated Ball open sprite included in ball_sprite
    # @return [String]
    def ball_open_sprite
      return ball_sprite
    end
    # Return the ball color of the Pokemon (flash)
    # @return [Color]
    def ball_color
      ball=GameData::Item.ball_data(@captured_with)
      if(ball)
        return ball.color
      else
        return Color.new(0,0,0)
      end
    end
    # Return the db_symbol of the Pokemon's item held
    # @return [Symbol]
    def item_db_symbol
      return GameData::Item.db_symbol(@battle_item) if $game_temp.in_battle
      return GameData::Item.db_symbol(@item_holding)
    end
    # Alias for item_holding
    # @return [Integer]
    def item_hold
      return @item_holding
    end
    # Change the Pokemon loyalty
    # @param v [Integer] the new loyalty
    def loyalty=(v)
      if(v < 0)
        v = 0
      elsif(v > 255)
        v = 255
      end
      @loyalty = v
    end
    # Is the Pokemon an egg ?
    # @return [Boolean]
    def egg
      return @step_remaining>0
    end
    alias egg? egg
    # Is the Pokemon not able to fight
    # @return [Boolean]
    def dead?
      return (@hp<=0 or self.egg?)
    end
    # Return the Pokemon rareness
    # @return [Integer]
    def rareness
      return @rareness ? @rareness : get_data.rareness
    end
    # Change the Pokemon rareness
    # @param v [Integer] the new rareness of the Pokemon
    def rareness=(v)
      @rareness=v.to_i
    end
    # Apply the effect of Transform (Morphing) on this Pokemon by using a target
    # @param target [PFM::Pokemon] the Pokemon to copy
    def morph(target)
      @sub_id=@id
      @sub_shiny=@shiny
      @sub_form=@form
      @id=target.id
      @shiny=target.shiny
      @form=target.form
      i = id = 0
      4.times do |i|
        @skills_set[i]=Skill.new(0) unless @skills_set[i]
        id = target.skills_set[i] ? target.skills_set[i].id : 0
        @skills_set[i].switch(id,5)
      end
      self.hp = (self.max_hp*self.hp_rate).to_i
    end
    # Return the db_symbol of the Pokemon
    # @return [Symbol]
    def db_symbol
      GameData::Pokemon.db_symbol(@id)
    end
    # Return the current ability of the Pokemon
    # @return [Integer]
    def ability
      return @ability_current
    end
    # Return the db_symbol of the Pokemon's Ability
    # @return [Symbol]
    def ability_db_symbol
      GameData::Abilities.db_symbol(self.ability)
    end
    # Return the battle effect of the Pokemon or the default battle effect
    # @return [Pokemon_Effect]
    def battle_effect
      return (@battle_effect or Pokemon_Effect.default_be)
    end
    # Return the normalized trainer id of the Pokemon
    # @return [Integer]
    def trainer_id
      return @trainer_id%100000
    end
    # Return if the Pokemon is from the player (he caught it)
    # @return [Boolean]
    def is_from_player?
      return (@trainer_id == $trainer.id and @trainer_name == $trainer.name)
    end
    # Return the height of the Pokemon
    # @return [Numeric]
    def height
      return get_data.height
    end
    # Return the weight of the Pokemon
    # @return [Numeric]
    def weight
      return get_data.weight
    end
    # Initialize the egg process of the Pokemon
    def egg_init
      @egg_in = $env.master_zone | Flag_40
      @egg_at = Time.new.to_i
      @step_remaining = get_data.hatch_step
      $quests.get_egg
    end
    # Ends the egg process of the Pokemon
    def egg_finish
      @captured_in = $env.master_zone|Flag_40
      @captured_at = Time.new.to_i
      @trainer_id = $trainer.id
      @trainer_name = $trainer.name
    end
    # Add a ribbon to the Pokemon
    # @param id [Integer] ID of the ribbon (in the ribbon text file)
    def add_ribbon(id)
      return if id < 0 or id > 50
      @ribbons << id unless @ribbons.include?(id)
    end
    # Has the pokemon got a ribbon ?
    # @return [Boolean]
    def ribbon_got?(id)
      return @ribbons.include?(id)
    end

    # Set the captured_in flags (to know from which game the pokemon came from)
    # @param flag [Integer] the new flag
    def flags=(flag)
      @captured_in = zone_id | (flag & 0xFFFF0000)
    end

    # Tell if the pokemon is from a past version
    # @return [Boolean]
    def from_past?
      return (@captured_in & 0x00FF0000) == Flag_39
    end

    # Get the zone id where the Pokemon has been found
    # @param special_zone [Integer, nil] if you want to use this function for stuff like egg_zone_id
    def zone_id(special_zone = nil)
      (special_zone || @captured_in) & 0x0000FFFF
    end

    private

    # Generate the gender of the Pokemon
    # @return [Integer] 1 if it's a male, 0 if it's a ungendered, 2 if it's a female
    def gender_generation
      data = get_data
      if data.female_rate >= 0
        return rand(100) < data.female_rate ? 2 : 1
      end
      return 0
    end
  end
end
