module GamePlay
  class MoveTeaching
    include UI::MoveTeaching

    # Update the graphics every frame
    def update_graphics
      # TODO
      # New text blinking
    end

    # Create the differents graphics of the UI
    def create_graphics
      super()
      create_background
      create_window
      create_pokemon_infos
      create_skill_description
      create_skills
      self.ui_visibility = false
    end

    # Set the visibility ON
    def ui_visibility=(visible)
      @base_ui.visible = visible
      @pokemon_infos.visible = visible
      @skill_description.visible = visible
      @skill_set.each { |sprite| sprite.visible = visible }
    end

    private

    # Create the background
    def create_background
      add_disposable @background = UI::BlurScreenshot.new(@__last_scene)
    end

    # Create the window background
    def create_window
      @base_ui = BaseBackground.new(@viewport)
    end

    # Create the Pokemon infos
    def create_pokemon_infos
      @pokemon_infos = PokemonInfos.new(@viewport)
    end

    # Create the Skill description view
    def create_skill_description
      @skill_description = SkillDescription.new(@viewport)
    end

    # Create the Skills (new one + skill_set)
    def create_skills
      create_skill_set
      create_new_skill
    end

    # Create the New skill view
    def create_new_skill
      @skill_set[4] = NewSkill.new(@viewport, 4)
    end

    # Create the Skillset
    def create_skill_set
      @skill_set = Array.new(4) { |index| Skill.new(@viewport, index) }
    end
  end
end
