module PFM
  class Pokemon
    # Apply the effect of Transform (Morphing) on this Pokemon by using a target
    # @param target [PFM::Pokemon] the Pokemon to copy
    def morph(target)
      @sub_id = @id
      @sub_code = @code
      @sub_form = @form
      @id = target.id
      @code = target.code
      @form = target.form
      4.times do |i|
        @skills_set[i] ||= Skill.new(0)
        skills_set[i].switch(target.skills_set[i]&.id || 0, 5)
      end
      self.hp = (max_hp * hp_rate).to_i.clamp(1, max_hp)
    end

    # Reset the battle stat stage and stuff related to battle
    def reset_stat_stage
      # TODO : Move and ajust this in the battle code
      @battle_stage = Array.new(7, 0)
      @critical_modifier = 0
      @ability_used = false
      @ability_current = @ability
      @confuse = false
      @state_count = 0
      @skills_set.each(&:reset)
      @skills_set.reject! { |skill| skill.id == 0 }
      if @sub_id
        @id = @sub_id
        @code = @sub_code
        @form = @sub_form
        @sub_id = @sub_code = @sub_form = nil
        self.hp = (max_hp * hp_rate).to_i
      end
      @battle_item = @item_holding
      @battle_item_data = []
      @type1 = @type2 = @type3 = nil
      @last_skill = 0
      @skill_use_times = 0
      @form = form_generation(-1) if db_symbol == :cherrim
      @status_count = 0 if toxic?
    end

    # Return the battle effect of the Pokemon or the default battle effect
    # @return [Pokemon_Effect]
    def battle_effect
      return @battle_effect || Pokemon_Effect.default_be
    end
  end
end
