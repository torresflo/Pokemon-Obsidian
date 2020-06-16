module Battle
  # Class that manage all the thing that are visually seen on the screen
  class Visual
    # Name of the background according to their processed zone_type
    BACKGROUND_NAMES = %w[back_building back_grass back_tall_grass back_taller_grass back_cave
                          back_mount back_sand back_pond back_sea back_under_water back_ice back_snow]

    # @return [Hash] List of the parallel animation
    attr_reader :parallel_animations

    # @return [Array] List of the animation
    attr_reader :animations

    # @return [Viewport] the viewport used to show the sprites
    attr_reader :viewport

    # @return [Viewport] the viewport used to show some UI part
    attr_reader :viewport_sub

    # @return [Array<BattleUI::GroundSprite>] the ground sprites
    attr_reader :grounds

    # @return [Array] the element to dispose on #dispose
    attr_reader :to_dispose

    # Create a new visual instance
    # @param battle_scene [Scene] scene that hold the logic object
    def initialize(battle_scene)
      @battle_scene = battle_scene
      @screenshot = $scene.snap_to_bitmap
      # All the battler by bank
      @battlers = {}
      # All the bars by bank
      @info_bars = {}
      # All the team info bar by bank
      @team_info = {}
      # All the animation currently being processed (automatically removed)
      @animations = []
      # All the parallel animations (manually removed)
      @parallel_animations = {}
      # All the thing to dispose on #dispose
      @to_dispose = []
      # Is the visual locking the update of the battle
      @locking = false
      # Create all the sprites
      create_viewport
      create_background
      create_battlers
      create_player_choice
      create_skill_choice
    end

    # Update the visuals
    def update
      @animations.each(&:update)
      @animations.delete_if(&:done?)
      @parallel_animations.each_value(&:update)
      update_battlers
      update_info_bars
    end

    # Dispose the visuals
    def dispose
      @to_dispose.each(&:dispose)
      @animations.clear
      @parallel_animations.clear
      @viewport.dispose
    end

    # Tell if the visual are locking the battle update (for transition purpose)
    def locking?
      @locking
    end

    # Unlock the battle scene
    def unlock
      @locking = false
    end

    # Lock the battle scene
    def lock
      if block_given?
        raise 'Race condition' if locking?

        @locking = true
        yield
        return @locking = false
      end
      @locking = true
    end

    private

    # Create the Visual viewport
    def create_viewport
      @viewport = Viewport.create(:main, 500)
      rc = @viewport.rect
      @viewport_sub = Viewport.new(rc.x, rc.y + rc.height - 48, rc.width, 48)
    end

    # Create the default background & the grounds that comes with it
    def create_background
      @background = ShaderedSprite.new(@viewport).set_bitmap(name = background_name, :battleback)
      @grounds = Array.new(@battle_scene.logic.bank_count) do |bank|
        BattleUI::GroundSprite.new(@viewport, name, bank)
      end
    end

    # Return the background name according to the current state of the player
    # @return [String]
    def background_name
      return $game_temp.battleback_name unless $game_temp.battleback_name.to_s.empty?
      zone_type = $env.get_zone_type
      zone_type += 1 if zone_type > 0 || $env.grass?
      log_debug("Background : ZoneType = #{zone_type} / BGName = #{BACKGROUND_NAMES[zone_type]}")
      return BACKGROUND_NAMES[zone_type].to_s
    end

    # Create the battler sprites (Trainer + Pokemon)
    def create_battlers
      infos = @battle_scene.battle_info
      (logic = @battle_scene.logic).bank_count.times do |bank|
        # create the trainer sprites
        infos.battlers[bank].each_with_index do |battler, position|
          sprite = BattleUI::TrainerSprite.new(@viewport, battler, bank, position, infos)
          store_battler_sprite(bank, -position - 1, sprite)
        end
        # Create the Pokemon sprites
        infos.vs_type.times do |position|
          sprite = BattleUI::PokemonSprite.new(@viewport)
          sprite.pokemon = logic.battler(bank, position)
          store_battler_sprite(bank, position, sprite)
          create_info_bar(bank, position)
        end
      end
      hide_info_bars(true)
    end

    # Update the battler sprites
    def update_battlers
      @battlers.each_value do |battlers|
        battlers.each_value(&:update)
      end
    end

    # Update the info bars
    def update_info_bars
      @info_bars.each_value do |info_bars|
        info_bars.each(&:update)
      end
    end

    # Create the info bar for a bank
    # @param bank [Integer]
    # @param position [Integer]
    def create_info_bar(bank, position)
      info_bars = (@info_bars[bank] ||= [])
      pokemon = @battle_scene.logic.battler(bank, position)
      info_bars[position] = BattleUI::InfoBar.new(@viewport, pokemon)
    end

    # Create the player choice
    def create_player_choice
      @player_choice_ui = BattleUI::PlayerChoice.new(@viewport_sub)
    end

    # Create the skill choice
    def create_skill_choice
      @skill_choice_ui = BattleUI::SkillChoice.new(@viewport_sub)
    end
  end
end
