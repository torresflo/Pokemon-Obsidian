module PFM
  # The InGame Pokemon management
  # @author Nuri Yuri
  class Pokemon
    # List of chance to get a specific ability on Pokemon generation
    ABILITY_CHANCES = [49, 98, 100]
    # Unknown flag (should always be up in Pokemon)
    FLAG_UNKOWN_USE = 0x0080_0000
    # Flag telling the Pokemon comes from this game (this fangame)
    FLAG_FROM_THIS_GAME = 0x0040_0000
    # Flag telling the Pokemon has been caught by the player
    FLAG_CAUGHT_BY_PLAYER = 0x0020_0000
    # Flag telling the Pokemon comes from present time (used to distinguish pokemon imported from previous games)
    FLAG_PRESENT_TIME = 0x0010_0000
    # Flag that tells the Pokemon object to generate Shiny with IV starting at 15
    Shiny_IV = false

    # Create a new Pokemon with specific parameters
    # @param id [Integer, Symbol] ID of the Pokemon in the database
    # @param level [Integer] level of the Pokemon
    # @param force_shiny [Boolean] if the Pokemon have 100% chance to be shiny
    # @param no_shiny [Boolean] if the Pokemon have 0% chance to be shiny (override force_shiny)
    # @param form [Integer] Form index of the Pokemon (-1 = automatic generation)
    # @param opts [Hash] Hash describing optional value you want to assign to the Pokemon
    # @option opts [String] :given_name Nickname of the Pokemon
    # @option opts [Integer, Symbol] :captured_with ID of the ball used to catch the Pokemon
    # @option opts [Integer] :captured_in ID of the zone where the Pokemon was caught
    # @option opts [Integer, Time] :captured_at Time when the Pokemon was caught
    # @option opts [Integer] :captured_level Level of the Pokemon when it was caught
    # @option opts [Integer] :egg_in ID of the zone where the egg was layed/found
    # @option opts [Integer, Time] :egg_at Time when the egg was layed/found
    # @option opts [Integer, String] :gender Forced gender of the Pokemon
    # @option opts [Integer] :nature Nature of the Pokemon
    # @option opts [Array<Integer>] :stats IV array ([hp, atk, dfe, spd, ats, dfs])
    # @option opts [Array<Integer>] :bonus EV array ([hp, atk, dfe, spd, ats, dfs])
    # @option opts [Integer, Symbol] :item ID of the item the Pokemon is holding
    # @option opts [Integer, Symbol] :ability ID of the ability the Pokemon has
    # @option opts [Integer] :rareness Rareness of the Pokemon (0 = not catchable, 255 = always catchable)
    # @option opts [Integer] :loyalty Happiness of the Pokemon
    # @option opts [Array<Integer, Symbol>] :moves Current Moves of the Pokemon (0 = default)
    # @option opts [Array(Integer, Integer)] :memo_text Text used for the memo ([file_id, text_id])
    # @option opts [String] :trainer_name Name of the trainer that caught / got the Pokemon
    # @option opts [Integer] :trainer_id ID of the trainer that caught / got the Pokemon
    def initialize(id, level, force_shiny = false, no_shiny = false, form = -1, opts = {})
      primary_data_initialize(id, level, force_shiny, no_shiny)
      catch_data_initialize(opts)
      form_data_initialize(form)
      stat_data_initialize(opts)
      moves_initialize(opts)
      item_holding_initialize(opts)
      ability_initialize(opts)
    end

    # Initialize the egg process of the Pokemon
    def egg_init
      @egg_in = $env.master_zone
      @egg_at = Time.new.to_i
      @step_remaining = data.hatch_step
      @item_holding = 0
      $quests.get_egg
    end

    # Ends the egg process of the Pokemon
    def egg_finish
      @captured_in = $env.master_zone
      self.flags = (FLAG_UNKOWN_USE | FLAG_FROM_THIS_GAME | FLAG_PRESENT_TIME | FLAG_CAUGHT_BY_PLAYER)
      @captured_at = Time.new.to_i
      @trainer_id = $trainer.id
      @trainer_name = $trainer.name
    end

    private

    # Method assigning the ID, level, shiny property
    # @param id [Integer, Symbol] ID of the Pokemon in the database
    # @param level [Integer] level of the Pokemon
    # @param force_shiny [Boolean] if the Pokemon have 100% chance to be shiny
    # @param no_shiny [Boolean] if the Pokemon have 0% chance to be shiny (override force_shiny)
    def primary_data_initialize(id, level, force_shiny, no_shiny)
      real_id = id.is_a?(Symbol) ? GameData::Pokemon.get_id(id) : id.to_i
      log_error("Bad Pokémon ID (#{id}) - Ignore if you opened the Pokedex") unless GameData::Pokemon.id_valid?(real_id)

      @id = real_id
      code_initialize
      self.shiny = force_shiny if force_shiny
      self.shiny = !no_shiny if no_shiny
      @level = level.clamp(1, max_level)
      @step_remaining = 0
      @ribbons = []
      @skill_learnt = []
      @skills_set = []
      @sub_id = nil
      @sub_code = nil
      @sub_form = nil
      @status = 0
      @status_count = 0
      @battle_stage = Array.new(7, 0)
      @last_skill = 0
      @position = 0
      @battle_effect = nil
      @battle_turns = 0
      @mega_evolved = false
    end

    # Code generation in order to get a shiny
    def code_initialize
      shiny_attempts.clamp(1, Float::INFINITY).times do
        @code = rand(0xFFFF_FFFF)
        break if shiny
      end
    end

    # Number of attempt to generate a shiny
    # @return [Integer]
    def shiny_attempts
      n = 1
      n += 2 if $bag.contain_item?(:shiny_charm)
      return n
    end

    # Method that initialize the data related to caching
    # @param opts [Hash] Hash describing optional value you want to assign to the Pokemon
    def catch_data_initialize(opts)
      @captured_with = GameData::Item[opts[:captured_with] || :"poké_ball"].id
      @captured_at = (opts[:captured_at] || Time.now).to_i
      @captured_level = opts[:captured_level] || @level
      @egg_in = opts[:egg_in]
      @egg_at = opts[:egg_at]
      @trainer_id = opts[:trainer_id] || $trainer.id
      @trainer_name = opts[:trainer_name] || $trainer.name
      @captured_in = opts[:captured_in] || $env.master_zone
      @given_name = opts[:given_name]
      @memo_text = opts[:memo_text]
      self.gender = opts[:gender] || (rand(100) < primary_data.female_rate ? 2 : 1)
      # Set flags
      self.flags = (FLAG_UNKOWN_USE | FLAG_FROM_THIS_GAME | FLAG_PRESENT_TIME)
      self.flags |= FLAG_CAUGHT_BY_PLAYER if @trainer_id == $trainer.id && @trainer_name == $trainer.name
    end

    # Method that initialize data related to form
    # @param form [Integer] Form index of the Pokemon (-1 = automatic generation)
    def form_data_initialize(form)
      form = form_generation(form)
      form = 0 unless GameData::Pokemon.all[id][form]
      @form = form
      exp_initialize
    end

    # Method that initialize the experience info of the Pokemon
    def exp_initialize
      self.exp = exp_list[@level].to_i
    end

    # Method that initialize the stat data
    # @param opts [Hash] Hash describing optional value you want to assign to the Pokemon
    def stat_data_initialize(opts)
      self.loyalty = opts[:loyalty] || data.base_loyalty
      self.rareness = opts[:rareness]
      ev_data_initialize(opts)
      iv_data_initialize(opts)
      @nature = (opts[:nature] || (@code >> 16)) % GameData::Natures.size
      self.hp = max_hp
    end

    # Method that initialize the EV data
    # @param opts [Hash] Hash describing optional value you want to assign to the Pokemon
    def ev_data_initialize(opts)
      @ev_hp = opts.dig(:bonus, GameData::EV::HP) || 0
      @ev_atk = opts.dig(:bonus, GameData::EV::ATK) || 0
      @ev_dfe = opts.dig(:bonus, GameData::EV::DFE) || 0
      @ev_spd = opts.dig(:bonus, GameData::EV::SPD) || 0
      @ev_ats = opts.dig(:bonus, GameData::EV::ATS) || 0
      @ev_dfs = opts.dig(:bonus, GameData::EV::DFS) || 0
    end

    # Method that initialize the IV data
    # @param opts [Hash] Hash describing optional value you want to assign to the Pokemon
    def iv_data_initialize(opts)
      iv_base = (Shiny_IV && shiny? ? 15 : 0)
      iv_rand = (Shiny_IV && shiny? ? 17 : 32)
      @iv_hp = opts.dig(:stats, GameData::EV::HP) || (Random::IV_HP.rand(iv_rand) + iv_base)
      @iv_atk = opts.dig(:stats, GameData::EV::ATK) || (Random::IV_ATK.rand(iv_rand) + iv_base)
      @iv_dfe = opts.dig(:stats, GameData::EV::DFE) || (Random::IV_DFE.rand(iv_rand) + iv_base)
      @iv_spd = opts.dig(:stats, GameData::EV::SPD) || (Random::IV_SPD.rand(iv_rand) + iv_base)
      @iv_ats = opts.dig(:stats, GameData::EV::ATS) || (Random::IV_ATS.rand(iv_rand) + iv_base)
      @iv_dfs = opts.dig(:stats, GameData::EV::DFS) || (Random::IV_DFS.rand(iv_rand) + iv_base)
    end

    # Method that initialize the moveset
    # @param opts [Hash] Hash describing optional value you want to assign to the Pokemon
    def moves_initialize(opts)
      moveset = data.move_set
      (moveset.size - 2).step(0, -2) do |i|
        if moveset[i].between?(0, level)
          learn_skill(moveset[i + 1]) unless skill_learnt?(moveset[i + 1])
          break if skills_set.size >= 4
        end
      end
      skills_set.reverse!
      # Load moves from options
      load_skill_from_array(opts[:moves]) if opts[:moves]
    end

    # Method that initialize the held item
    # @param opts [Hash] Hash describing optional value you want to assign to the Pokemon
    def item_holding_initialize(opts)
      # Get item_id list & comparable % list
      items = data.items
      item_id_array = items.select.with_index { |_, index| index.even? }
      item_percent_array = items.select.with_index { |_, index| index.odd? }.reduce([]) do |memo, value|
        memo << memo[-1].to_i + value
      end
      # Take the item according to the rng (% in item_percent_array should be higher than the rng val)
      rng = rand(100)
      @item_holding = item_id_array[item_percent_array.find_index { |value| value > rng } || 101]
      @item_holding = GameData::Item[opts[:item] || @item_holding.to_i].id
    end

    # Method that initialize the ability
    # @param opts [Hash] Hash describing optional value you want to assign to the Pokemon
    def ability_initialize(opts)
      ability = data.abilities
      if opts[:ability]
        @ability = opts[:ability]
      else
        ability_chance = rand(100)
        @ability = ability[@ability_index = ABILITY_CHANCES.find_index { |value| value > ability_chance }].to_i
      end
      @ability = GameData::Abilities.find_using_symbol(@ability) unless @ability.is_a?(Integer)
      @ability_current = @ability
      @ability_used = false
    end
  end
end
