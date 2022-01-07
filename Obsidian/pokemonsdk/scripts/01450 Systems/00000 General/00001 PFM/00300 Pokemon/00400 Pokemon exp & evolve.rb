module PFM
  class Pokemon
    include Hooks
    # Tell if PSDK test evolve on form 0 or the current form
    EVOLVE_ON_FORM0 = PSDK_CONFIG.always_use_form0_for_evolution
    # List of key in evolution Hash that corresponds to the expected ID when evolution is valid
    # @return [Array<Symbol>]
    SPECIAL_EVOLUTION_ID = %i[trade id]

    # List of evolution criteria
    # @return [Hash{ Symbol => Proc }]
    @evolution_criteria = {}
    # List of evolution criteria required for specific reason
    # @return [Hash{ Symbol => Array<Symbol> }]
    @evolution_reason_required_criteria = {}
    class << self
      # List of evolution criteria
      # @return [Hash{ Symbol => Proc }]
      attr_reader :evolution_criteria
      # List of evolution criteria required for specific reason
      # @return [Hash{ Symbol => Array<Symbol> }]
      attr_reader :evolution_reason_required_criteria

      # Add a new evolution criteria
      # @param key [Symbol] hash key expected in special evolution
      # @param reasons [Array<Symbol>] evolution reasons that require this criteria in order to allow evolution
      # @param block [Proc] executed proc for special evolution test, will receive : value, extend_data, reason
      def add_evolution_criteria(key, reasons = nil, &block)
        @evolution_criteria[key] = block
        reasons&.each do |reason|
          (@evolution_reason_required_criteria[reason] ||= []) << key
        end
      end
    end

    # Return the base experience of the Pokemon
    # @return [Integer]
    def base_exp
      return GameData::Pokemon[@sub_id || @id, @form].base_exp
    end

    # Return the exp curve type ID
    # @return [Integer]
    def exp_type
      return data.exp_type
    end

    # Return the exp curve
    # @return [Array<Integer>]
    def exp_list
      return GameData::EXP_TABLE[exp_type]
    end

    # Return the required total exp (so including old levels) to increase the Pokemon's level
    # @return [Integer]
    def exp_lvl
      data = GameData::EXP_TABLE[exp_type]
      v = data[@level + 1]
      return data[@level] if !v || PFM.game_state&.level_max_limit.to_i <= @level

      return v
    end

    # Return the text of the amount of exp the pokemon needs to go to the next level
    # @return [String]
    def exp_remaining_text
      expa = exp_lvl - exp
      expa = 0 if expa < 0
      return expa.to_s
    end

    # Return the text of the current pokemon experience
    # @return [String]
    def exp_text
      @exp.to_s
    end

    # Change the Pokemon total exp
    # @param v [Integer] the new exp value
    def exp=(v)
      @exp = v.to_i
      exp_lvl = self.exp_lvl
      if exp_lvl >= @exp
        exp_last = GameData::EXP_TABLE[exp_type][@level]
        delta = exp_lvl - exp_last
        current = exp - exp_last
        @exp_rate = (delta == 0 ? 1 : current / delta.to_f)
      else
        @exp_rate = (@level < PFM.game_state.level_max_limit ? 1 : 0)
      end
    end

    # Increase the level of the Pokemon
    # @return [Boolean] if the level has successfully been increased
    def level_up
      return false if @level >= PFM.game_state.level_max_limit

      exp_last = GameData::EXP_TABLE[exp_type][@level]
      delta = exp_lvl - exp_last
      self.exp += (delta - (exp - exp_last))
      update_loyalty if $game_temp.in_battle
      return true
    end

    # Update the Pokemon loyalty
    def update_loyalty
      value = 3
      value = 4 if loyalty < 200
      value = 5 if loyalty < 100
      value *= 2 if GameData::Item.db_symbol(captured_with) == :luxury_ball
      value *= 1.5 if item_db_symbol == :soothe_bell
      self.loyalty += value.floor
    end

    # Generate the level up stat list for the level up window
    # @return [Array<Array<Integer>>] list0, list1 : old, new basis value
    def level_up_stat_refresh
      st = $game_temp.in_battle
      $game_temp.in_battle = false
      list0 = [max_hp, atk_basis, dfe_basis, ats_basis, dfs_basis, spd_basis]
      @level += 1 if @level < PFM.game_state.level_max_limit
      self.exp = exp_list[@level] if @exp < exp_list[@level].to_i
      self.exp = exp # Fix the exp amount
      hp_diff = list0[0] - @hp
      list1 = [max_hp, atk_basis, dfe_basis, ats_basis, dfs_basis, spd_basis]
      self.hp = (max_hp - hp_diff) if @hp > 0
      $game_temp.in_battle = st
      return [list0, list1]
    end

    # Show the level up window
    # @param list0 [Array<Integer>] old basis stat list
    # @param list1 [Array<Integer>] new basis stat list
    # @param z_level [Integer] z superiority of the Window
    def level_up_window_call(list0, list1, z_level)
      vp = $scene&.viewport
      window = UI::LevelUpWindow.new(vp, self, list0, list1)
      window.z = z_level
      Graphics.sort_z
      until Input.trigger?(:A)
        window.update
        Graphics.update
      end
      $game_system.se_play($data_system.decision_se)
      window.dispose
    end

    # Change the level of the Pokemon
    # @param lvl [Integer] the new level of the Pokemon
    def level=(lvl)
      return if lvl == @level

      lvl = lvl.clamp(1, PFM.game_state.level_max_limit)
      @exp = exp_list[lvl]
      @exp_rate = 0
      @level = lvl
    end

    # Check if the Pokemon can evolve and return the evolve id if possible
    # @param reason [Symbol] evolve check reason (:level_up, :trade, :stone)
    # @param extend_data [Hash, nil] extend_data generated by an item
    # @return [Array<Integer, nil>, false] if the Pokemon can evolve, the evolve id, otherwise false
    def evolve_check(reason = :level_up, extend_data = nil)
      return false if item_db_symbol == :everstone

      data = EVOLVE_ON_FORM0 ? primary_data : self.data
      if reason == :level_up
        return data.evolution_id if data.evolution_id != 0 && data.evolution_level.to_i.between?(1, @level)

        if PSDK_CONFIG.use_form0_when_no_evolution_data
          if data.evolution_id == 0 && primary_data.evolution_id != 0 && primary_data.evolution_level.to_i.between?(1, @level)
            return data.evolution_id
          end
        end
      end

      unless data.special_evolution
        data = primary_data if PSDK_CONFIG.use_form0_when_no_evolution_data
        return false unless data.special_evolution
      end

      required_criterias = Pokemon.evolution_reason_required_criteria[reason] || []
      criteria = Pokemon.evolution_criteria
      expected_evolution = data.special_evolution.find do |evolution|
        next unless evolution.is_a?(Hash)
        next unless (required_criterias - evolution.keys).empty?

        next evolution.all? { |key, value| criteria[key] && instance_exec(value, extend_data, reason, &criteria[key]) }
      end

      return false unless expected_evolution

      id = expected_evolution[SPECIAL_EVOLUTION_ID.find { |key| expected_evolution[key] }]
      return id, expected_evolution[:form]
    end
    # Exchanged with another pokemon
    add_evolution_criteria(:trade_with, [:trade_with]) { |value, extend_data| extend_data == value }
    # Minimum level
    add_evolution_criteria(:min_level) { |value| @level >= value.to_i }
    # Maximum level
    add_evolution_criteria(:max_level) { |value| @level <= value.to_i }
    # Holding an item
    add_evolution_criteria(:item_hold) { |value| value == @item_holding || value == item_db_symbol }
    # Minimum loyalty
    add_evolution_criteria(:min_loyalty) { |value| @loyalty >= value.to_i }
    # Maximum loyalty
    add_evolution_criteria(:max_loyalty) { |value| @loyalty <= value.to_i }
    # Move 1
    add_evolution_criteria(:skill_1) { |value| skill_learnt?(value) }
    # Move 2
    add_evolution_criteria(:skill_2) { |value| skill_learnt?(value) }
    # Move 3
    add_evolution_criteria(:skill_3) { |value| skill_learnt?(value) }
    # Move 4
    add_evolution_criteria(:skill_4) { |value| skill_learnt?(value) }
    # On specific weather
    add_evolution_criteria(:weather) { |value| $env.current_weather_db_symbol == value }
    # Being on a specfic tag
    add_evolution_criteria(:env) { |value| $game_player.system_tag == value }
    # Having a specific gender
    add_evolution_criteria(:gender) { |value| @gender == value }
    # Evolving from stone
    add_evolution_criteria(:stone, [:stone]) { |value, extend_data, reason| reason == :stone && value == extend_data }
    # Evolving on a specific day/night cycle
    add_evolution_criteria(:day_night) { |value| value == $game_variables[Yuki::Var::TJN_Tone] }
    # On a function call
    add_evolution_criteria(:func) { |value| send(value) }
    # Being on a specific map
    add_evolution_criteria(:maps) { |value| value.include?($game_map.map_id) }
    # Being traded
    add_evolution_criteria(:trade, [:trade]) { |_value, _extend_data, reason| reason == :trade }
    # ID field auto validation
    add_evolution_criteria(:id) { true }
    # FORM field auto validation
    add_evolution_criteria(:form) { true }
    # On a specific switch
    add_evolution_criteria(:switch) { |value| $game_switches[value] }
    # Having a specific nature
    add_evolution_criteria(:nature) { |value| nature_id == value }

    # Method that actually make a Pokemon evolve
    # @param id [Integer] ID of the Pokemon that evolve
    # @param form [Integer, nil] form of the Pokemon that evolve
    def evolve(id, form)
      old_evolution_id = self.id
      old_evolution_form = self.form
      hp_diff = self.max_hp - self.hp
      self.id = id
      if form
        self.form = form
      else
        form_calibrate(:evolve)
      end
      return unless $actors.include?(self) # Don't do te rest if the pokemon isn't in the current party

      # evolution_items = (data.special_evolution || []).map { |hash| hash[:item_hold] || 0 }
      previous_pokemon_evolution_method = GameData::Pokemon[old_evolution_id, old_evolution_form].special_evolution
      evolution_items = (previous_pokemon_evolution_method || []).map { |hash| hash[:item_hold] || 0 }
      self.item_holding = 0 if evolution_items.include?(item_holding) || evolution_items.include?(item_db_symbol)
      # Normal skill learn
      check_skill_and_learn
      # Evolution skill learn
      check_skill_and_learn(false, 0)
      # Pokedex register (self is used to be sure we get the right information)
      $pokedex.mark_seen(self.id, self.form, forced: true)
      $pokedex.mark_captured(self.id)
      $pokedex.pokemon_captured_inc(self.id)
      # Refresh hp
      self.hp = (self.max_hp - hp_diff) if self.hp > 0
      exec_hooks(PFM::Pokemon, :evolution, binding)
    end

    # Add Shedinja evolution
    Hooks.register(PFM::Pokemon, :evolution, 'Shedinja Evolution') do
      next unless id == 291 && $actors.size < 6 && $bag.contain_item?(4)

      # @type [PFM::Pokemon]
      munja = dup
      munja.id = 292
      munja.hp = munja.max_hp
      $actors << munja
      $bag.remove_item(4, 1)
      $pokedex.mark_seen(292, forced: true)
      $pokedex.mark_captured(292)
    end

    # Change the id of the Pokemon
    # @param new_id [Integer] the new id of the Pokemon
    def id=(new_id)
      @character = nil
      if new_id && GameData::Pokemon.id_valid?(new_id) && (forms = GameData::Pokemon.get_forms(new_id))
        @id = new_id
        @form = 0 unless forms[@form]
        @form = form_generation(-1) if @form == 0
        @form = 0 unless forms[@form]
        update_ability
      end
    end

    # Update the Pokemon Ability
    def update_ability
      return unless @ability_index

      @ability = get_data.abilities[@ability_index.to_i]
    end

    # Check evolve condition to evolve in Hitmonlee (kicklee)
    # @return [Boolean] if the condition is valid
    def elv_kicklee
      atk > dfe
    end

    # Check evolve condition to evolve in Hitmonchan (tygnon)
    # @return [Boolean] if the condition is valid
    def elv_tygnon
      atk < dfe
    end

    # Check evolve condition to evolve in Hitmontop (Kapoera)
    # @return [Boolean] if the condition is valid
    def elv_kapoera
      atk == dfe
    end

    # Check evolve condition to evolve in Silcoon (Armulys)
    # @return [Boolean] if the condition is valid
    def elv_armulys
      ((@code & 0xFFFF) % 10) <= 4
    end

    # Check evolve condition to evolve in Cascoon (Blindalys)
    # @return [Boolean] if the condition is valid
    def elv_blindalys
      !elv_armulys
    end

    # Check evolve condition to evolve in Mantine
    # @return [Boolean] if the condition is valid
    def elv_demanta
      PFM.game_state.has_pokemon?(223)
    end

    # Check evolve condition to evolve in Pangoro (Pandarbare)
    # @return [Boolean] if the condition is valid
    def elv_pandarbare
      return $actors.any? { |pokemon| pokemon&.type_dark? }
    end

    # Check evolve condition to evolve in Malamar (Sepiatroce)
    # @note uses :DOWN to validate the evolve condition
    # @return [Boolean] if the condition is valid
    def elv_sepiatroce
      return Input.press?(:DOWN)
    end

    # Check evolve condition to evolve in Sylveon (Nymphali)
    # @return [Boolean] if the condition is valid
    def elv_nymphali
      return @skills_set.any? { |skill| skill&.type_fairy? }
    end
  end
end
