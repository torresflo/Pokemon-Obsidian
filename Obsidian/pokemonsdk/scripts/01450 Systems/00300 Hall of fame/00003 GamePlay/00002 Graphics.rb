module GamePlay
  class Hall_of_Fame

    include UI::Hall_of_Fame

    # Create the graphics for the UI
    def create_graphics
      super()
      create_background
      create_type_background
      create_pokemon_battler_stack
      create_pokemon_text_boxes
      create_congratulation_text_boxes
      create_pokemon_stars_animation
      create_graveyard_anim
      create_turning_ball
      create_party_battler_stack
      create_league_champion_text_box
      create_trainer_infos_text_box
      create_end_stars
    end

    # Launch each phase of the animation then update the looping animations
    def update_graphics
      case @animation_state
      when 0
        animation_phase_1
      when 1
        if PFM.game_state.nuzlocke.enabled? && !@graveyard.empty?
          animation_phase_2
        else
          @animation_state += 1
        end
      when 2
        animation_phase_3
      when 3
        # Every animation is finished so there's only two things to update
        update_turning_ball
        update_end_stars_anim
      end
    end

    # Create the background
    def create_background
      @background = Sprite.new(@viewport)
      @background.set_bitmap('hall_of_fame/black_background', :interface)
    end

    # Create the type background that is displayed during phase 1
    def create_type_background
      @type_background = Type_Background.new(@viewport)
    end

    # Create the stack containing the Pokemon's battler that is displayed during phase 1
    def create_pokemon_battler_stack
      @pkm_battler_stack = Pokemon_Battler_Stack.new(@viewport)
    end

    # Create the stars animation that is displayed during phase 1
    def create_pokemon_stars_animation
      @pkm_stars_anim = Pokemon_Stars_Animation.new(@viewport)
    end

    # Update the stars animation (only during phase 1, updated by launch_animation)
    def update_pokemon_stars_animation
      @pkm_stars_anim.update
    end

    # Create the boxes containing the text about the Pokemon that are displayed during phase 1
    def create_pokemon_text_boxes
      @pkm_text_boxes = []
      $actors.each do |pkm|
        @pkm_text_boxes << Pokemon_Text_Box.new(@viewport, pkm)
      end
    end

    # Create the congratulations boxes that are displayed during phase 1
    def create_congratulation_text_boxes
      @congrats_text_boxes = []
      $actors.each do |pkm|
        @congrats_text_boxes << Congratulation_Text_Box.new(@viewport, pkm)
      end
    end

    # Create the stack that contains everything needed for phase 2 animation
    def create_graveyard_anim
      @graveyard_stack = Graveyard_Animation_Stack.new(@viewport)
    end

    # Create the turning ball that is displayed during phase 3
    def create_turning_ball
      @ball = Turning_Pokeball.new(@viewport)
    end

    # Update the turning ball animation during phase 3 and after
    def update_turning_ball
      @ball.update_anim
    end

    # Create the stack containing every battlers displayed during phase 3
    def create_party_battler_stack
      @party_battler = Party_Battler_Stack.new(@viewport)
    end

    # Create the box containing the league champion text displayed during phase 3
    def create_league_champion_text_box
      @league_champ_box = League_Champion_Text_Box.new(@viewport)
    end

    # Create the box containing the trainer texts displayed during phase 3
    def create_trainer_infos_text_box
      @trainer_infos_box = Trainer_Infos_Text_Box.new(@viewport)
    end

    # Create the final stars animation that is displayed after phase 3
    def create_end_stars
      @end_stars_anim = End_Stars_Animation.new(@viewport)
    end

    # Update the final stars animation after phase 3
    def update_end_stars_anim
      @end_stars_anim.update
    end

    # Launch the given animation
    # @param animation [Yuki::Animation] the animation to run
    def launch_animation(animation)
      animation.start
      until animation.done?
        parallel_animating if @parallel_update
        animation.update
        Graphics.update
      end
    end

    # Update some parallel animation if the context demand it
    def parallel_animating
      if @animation_state == 0
        update_pokemon_stars_animation
      elsif @animation_state == 2
        update_turning_ball
      end
    end
  end
end
