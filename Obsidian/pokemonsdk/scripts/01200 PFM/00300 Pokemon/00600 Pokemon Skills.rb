module PFM
  class Pokemon
    # Return the list of skill/move ID of the Pokemon
    # @return [Array<Integer>]
    def skills
      list = []
      return list if @step_remaining > 0
      @skills_set.each do |i|
        list << i.id if i
      end
      return list
    end

    # Return the skill at an index in the moveset of the Pokemon
    # @return [PFM::Skill, nil]
    def ss(index)
      return @skills_set[index]
    end

    # Learn a new skill
    # @param id [Integer, Symbol] ID of the skill in the database
    # @return [Boolean, nil] true = learnt, false = already learnt, nil = couldn't learn
    def learn_skill(id)
      id = GameData::Skill.get_id(id) if id.is_a?(Symbol)
      return false if skill_learnt?(id, true)
      if @skills_set.size < 4
        @skills_set << PFM::Skill.new(id)
        @skill_learnt << id unless @skill_learnt.include?(id)
        return true
      end
      return nil
    end

    # Forget a skill at a specific index
    # @param index [Integer] index of the skill to forget
    def forget_skill_index(index)
      @skills_set[index] = nil
      @skills_set.compact!
    end

    # Forget a skill by its id
    # @param id [Integer, Symbol] ID of the skill in the database
    def forget_skill(id)
      id = GameData::Skill.get_id(id) if id.is_a?(Symbol)
      @skills_set.each_with_index do |skill, i|
        @skills_set[i] = nil if skill && skill.id == id
      end
      @skills_set.compact!
    end

    # Replace a skill to an other skill
    # @param id_old [Integer, Symbol] id of the old skill
    # @param id_new [Integer, Symbol] id of the new skill
    # @return [Boolean, nil] false = id_new found in the skills, nil = id_old not found, true = skill replaced
    # @deprecated Never used.
    def convert_skill(id_old, id_new)
      id_old = GameData::Skill.get_id(id_old) if id_old.is_a?(Symbol)
      id_new = GameData::Skill.get_id(id_new) if id_new.is_a?(Symbol)
      @skills_set.each_with_index do |skill, i|
        if skill && skill.id == id_new
          return false
        elsif skill && skill.id == id_old
          @skills_set[i] = PFM::Skill.new(id_new)
          @skill_learnt << id_new unless @skill_learnt.include?(id_new)
          return true
        end
      end
      return nil
    end

    # Swap the position of two skills in the skills_set
    # @param index1 [Integer] Index of the first skill to swap
    # @param index2 [Integer] Index of the second skill to swap
    def swap_skills_index(index1, index2)
      @skills_set[index1], @skills_set[index2] = @skills_set[index2], @skills_set[index1]
      @skills_set.compact!
    end

    # Replace the skill at a specific index
    # @param index [Integer] index of the skill to replace by a new skill
    # @param id [Integer, Symbol] id of the new skill in the database
    def replace_skill_index(index, id)
      id = GameData::Skill.get_id(id) if id.is_a?(Symbol)
      return if index >= 4
      @skills_set[index] = PFM::Skill.new(id)
      @skill_learnt << id unless @skill_learnt.include?(id)
    end

    # Has the pokemon already learnt a skill ?
    # @param id [Integer, Symbol] id of the skill
    # @param only_in_moveset [Boolean] if the function only check in the current moveset
    # @return [Boolean]
    def skill_learnt?(id, only_in_moveset = true)
      return false if egg?
      id = GameData::Skill.get_id(id) if id.is_a?(Symbol)
      @skills_set.each do |skill|
        return true if skill && skill.id == id
      end
      return false if only_in_moveset
      return true if @skill_learnt.include?(id)
      return false
    end
    alias has_skill? skill_learnt?

    # Return the skill index of a skill in the moveset of the Pokemon
    # @param skill [PFM::Skill] the skill
    # @return [Integer] the index of the skill
    def get_skill_position(skill)
      return false if egg?
      @skills_set.each_with_index do |sk, i|
        return i if sk && sk.id == skill.id
      end
      return 0
    end

    # Find a skill in the moveset of the Pokemon
    # @param id [Integer, Symbol] ID of the skill in the database
    # @return [PFM::Skill, false]
    def find_skill(id)
      return false if egg?
      id = GameData::Skill.get_id(id) if id.is_a?(Symbol)
      @skills_set.each do |skill|
        return skill if skill && skill.id == id
      end
      return false
    end

    # Find the last skill used position in the moveset of the Pokemon
    # @return [Integer]
    def find_last_skill_position
      @skills_set.each_with_index do |skill, i|
        return i if skill && skill.id == @last_skill
      end
      return 0
    end

    # Check if the Pokemon can learn a new skill and make it learn the skill
    # @param silent [Boolean] if the skill is automatically learnt or not (false = show skill learn interface & messages)
    # @param level [Integer] The level to check in order to learn the moves
    def check_skill_and_learn(silent = false, level = @level)
      move_set = data.move_set
      0.step(move_set.size - 1, 2) do |i|
        id = move_set[i + 1]
        if level == move_set[i] && !skill_learnt?(id)
          if silent
            @skills_set << ::PFM::Skill.new(id)
            @skills_set.shift if @skills_set.size > 4
            @skill_learnt << id unless @skill_learnt.include?(id)
          else
            ::GamePlay::Skill_Learn.new(self, id).main
          end
        end
      end
    end

    # Check if the Pokemon can learn a skill
    # @param skill_id [Integer, Symbol] id of the skill in the database
    # @return [Boolean, nil] nil = learnt, false = cannot learn, true = can learn
    def can_learn?(skill_id)
      return false if egg?

      skill_id = GameData::Skill.get_id(skill_id) if skill_id.is_a?(Symbol)
      return nil if skill_learnt?(skill_id)

      move_set = data.move_set
      0.step(move_set.size - 1, 2) do |i|
        return true if move_set[i + 1] == skill_id
      end
      return true if data.tech_set.include?(skill_id)
      return true if data.master_moves.include?(skill_id)

      return false
    end

    # Get the number of skill of a specific category
    # @param atk_class [Integer] 1 = atk, 2 = spe, 3 = status
    # @return [Integer]
    def skill_category_amount(atk_class)
      count = 0
      @skills_set.each do |skill|
        count += 1 if skill && skill.atk_class == atk_class
      end
      return count
    end

    # Get the list of all the skill the Pokemon can learn again
    # @param mode [Integer] Define the moves that can be learnt again :
    #   1 = breed_moves + learnt + potentially_learnt
    #   2 = all moves
    #   other = learnt + potentially_learnt
    # @return [Array<Integer>]
    def remindable_skills(mode = 0)
      move_set = data.move_set
      level = mode == 2 ? Float::INFINITY : @level
      remindable_ids = []
      # Collect natural skills
      0.step(move_set.size - 1, 2) do |i|
        remindable_ids << move_set[i + 1] if level >= move_set[i]
      end
      # Collect learnt skills
      remindable_ids.concat(@skill_learnt)
      # Collect the bread move skills
      remindable_ids.concat(data.breed_moves) if mode == 1
      # Clean the list
      remindable_ids.uniq!
      # Remove the skill the pokemon actually has and return the array of PFM::Skills
      return (remindable_ids - skills)
    end

    # Load the skill from an Array
    # @param skills [Array] the skills array (containing IDs or Symbols)
    def load_skill_from_array(skills)
      skills.each_with_index do |skill, j|
        next if skill == 0
        skill = GameData::Skill.get_id(skill) if skill.is_a?(Symbol)
        if skill.is_a?(Integer)
          replace_skill_index(j, skill)
        elsif skill.class == String
          log_error("#{skill} est irrecevable, vous devez spécifier un id ! PSDK_ERR n°000_001")
        end
      end
      skills_set.compact!
    end

    # Compatibility for deprecated battle engine
    alias moveset skills_set
  end
end
