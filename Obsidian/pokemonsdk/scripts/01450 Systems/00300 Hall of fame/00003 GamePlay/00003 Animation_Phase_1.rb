module GamePlay
  class Hall_of_Fame
    ####################################################################################################################
    # Description of each anim of animation_phase_1                                                                    #
    # For each p1_anim_x there is a p1_resolver_anim_x, which describe every parameters for each animation method      #
    # Every parameters name you'll see in those methods is ARBITRARY and are just here to name things, they do not     #
    #   have anything to do with already existing methods.                                                             #
    ####################################################################################################################
    # p1_anim_1 : Just a wait of 2 seconds in order for the music to launch                                            #
    #                                                                                                                  #
    # p1_anim_2 : Sliding from right to left for player's Pokemon's back sprites in 0.5 second                         #
    #                                                                                                                  #
    # p1_anim_3 : Slight movement from left to right of the Congratulation_Text_Box in 0.5 second                      #
    #                                                                                                                  #
    # p1_anim_4 : Slight movement from right to left of the Pokemon_Text_Box in 0.5 second                             #
    #             Change of opacity for each Type_Background.foregrounds in 0.2 second from 0 to 50                    #
    #             Change of opacity for each Type_Background.backgrounds in 0.2 second from 0 to 50                    #
    #             Slight movement from left to right for player's Pokemon's front sprites                              #
    #             Play the Hall of Fame sound                                                                          #
    #                                                                                                                  #
    # p1_anim_5 : Play the cry of the Pokemon                                                                          #
    #             Move the colored shadow of the Pokemon                                                               #
    #             Move the translucent type background                                                                 #
    #                                                                                                                  #
    # p1_anim_6 : Change the opacity of the translucent type background                                                #
    #             Move the translucent type background                                                                 #
    #             Wait 1 second                                                                                        #
    #                                                                                                                  #
    # p1_anim_7 : Change the opacity of the type background                                                            #
    #             Move everything out of the screen                                                                    #
    #             Wait 0.3 second                                                                                      #
    ####################################################################################################################

    private

    def animation_phase_1
      @anim_count = 0
      launch_animation(p1_anim_1)
      until @anim_count == $actors.size
        launch_animation(p1_anim_2(p1_resolver_anim_2))
        launch_animation(p1_anim_3(p1_resolver_anim_3))
        launch_animation(p1_anim_4(p1_resolver_anim_4))
        @parallel_update = true
        launch_animation(p1_anim_5(p1_resolver_anim_5))
        @parallel_update = false
        @pkm_stars_anim.reset
        launch_animation(p1_anim_6(p1_resolver_anim_6))
        launch_animation(p1_anim_7(p1_resolver_anim_7))
        @anim_count += 1
      end
      @animation_state += 1
    end

    def p1_resolver_anim_2
      resolver = {
        sprite_from_x: @pkm_battler_stack.battlebacks[@anim_count].x,
        sprite_from_y: @pkm_battler_stack.battlebacks[@anim_count].y,
        sprite_to_x: @pkm_sprite_anim::X_LEFT,
        sprite: @pkm_battler_stack.battlebacks[@anim_count]
      }
      resolver = resolver.method(:fetch)
      return resolver
    end

    def p1_resolver_anim_3
      resolver = {
        up_box_from_x: @congrats_text_boxes[@anim_count].x,
        up_box_from_y: @congrats_text_boxes[@anim_count].y,
        up_box_to_x: @congrats_text_boxes[@anim_count].x + @congrats_text_boxes[@anim_count].width,
        up_box: @congrats_text_boxes[@anim_count]
      }
      resolver = resolver.method(:fetch)
      return resolver
    end

    def p1_resolver_anim_4
      type2_to_opacity = $actors[@anim_count].type1 == 10 ? 0 : 127
      resolver = {
        down_box_from_x: @pkm_text_boxes[@anim_count].x,
        down_box_from_y: @pkm_text_boxes[@anim_count].y,
        down_box_to_x: @pkm_text_boxes[@anim_count].x - @pkm_text_boxes[@anim_count].width,
        down_box: @pkm_text_boxes[@anim_count],
        type_from_opacity: @type_background.type_foregrounds[@anim_count].opacity,
        type_to_opacity: 127,
        type: @type_background.type_foregrounds[@anim_count],
        type2_from_opacity: @type_background.type_backgrounds[@anim_count].opacity,
        type2_to_opacity: type2_to_opacity,
        type2: @type_background.type_backgrounds[@anim_count],
        sprite_from_x: @pkm_battler_stack.battlefronts[@anim_count].x,
        sprite_from_y: @pkm_battler_stack.battlefronts[@anim_count].y,
        sprite_to_x: @pkm_sprite_anim::X_RIGHT,
        sprite: @pkm_battler_stack.battlefronts[@anim_count]
      }
      resolver = resolver.method(:fetch)
      return resolver
    end

    def p1_resolver_anim_5
      resolver = {
        sprite2_from_x: @pkm_battler_stack.battlefronts[@anim_count].x,
        sprite2_from_y: @pkm_battler_stack.withcolorbacks[@anim_count].y,
        sprite2_to_x: @pkm_sprite_anim::X_COLOR_RIGHT,
        sprite2: @pkm_battler_stack.withcolorbacks[@anim_count],
        type2_from_x: @type_background.type_backgrounds[@anim_count].x,
        type2_from_y: @type_background.type_backgrounds[@anim_count].y,
        type2_to_x: @type_background.type_backgrounds[@anim_count].x - 15,
        type2_to_x2: @type_background.type_backgrounds[@anim_count].x - 20,
        type2: @type_background.type_backgrounds[@anim_count],
        sound: pkm_cry_filename
      }
      resolver = resolver.method(:fetch)
      return resolver
    end

    def p1_resolver_anim_6
      resolver = {
        type2_from_x: @type_background.type_backgrounds[@anim_count].x,
        type2_from_y: @type_background.type_backgrounds[@anim_count].y,
        type2_to_x: @type_background.type_backgrounds[@anim_count].x - 5,
        type2: @type_background.type_backgrounds[@anim_count]
      }
      resolver = resolver.method(:fetch)
      return resolver
    end

    def p1_resolver_anim_7
      resolver = {
        type_from_opacity: @type_background.type_foregrounds[@anim_count].opacity,
        type_to_opacity: 0,
        type: @type_background.type_foregrounds[@anim_count],
        up_box_from_x: @congrats_text_boxes[@anim_count].x,
        up_box_from_y: @congrats_text_boxes[@anim_count].y,
        up_box_to_x: @congrats_text_boxes[@anim_count].x - @congrats_text_boxes[@anim_count].width,
        up_box: @congrats_text_boxes[@anim_count],
        down_box_from_x: @pkm_text_boxes[@anim_count].x,
        down_box_from_y: @pkm_text_boxes[@anim_count].y,
        down_box_to_x: @pkm_text_boxes[@anim_count].x + @pkm_text_boxes[@anim_count].width,
        down_box: @pkm_text_boxes[@anim_count],
        sprite_from_x: @pkm_battler_stack.battlefronts[@anim_count].x,
        sprite_from_y: @pkm_battler_stack.battlefronts[@anim_count].y,
        sprite_to_x: @pkm_sprite_anim::X_LEFT,
        sprite: @pkm_battler_stack.battlefronts[@anim_count],
        sprite2_from_x: @pkm_battler_stack.withcolorbacks[@anim_count].x,
        sprite2_from_y: @pkm_battler_stack.withcolorbacks[@anim_count].y,
        sprite2_to_x: @pkm_sprite_anim::X_LEFT,
        sprite2: @pkm_battler_stack.withcolorbacks[@anim_count]
      }
      resolver = resolver.method(:fetch)
      return resolver
    end

    def p1_anim_1
      animation = Yuki::Animation.instance_eval {
        wait(2)
      }.root
      return animation
    end

    def p1_anim_2(resolver)
      animation = Yuki::Animation.instance_eval {
        move(0.5, :sprite, :sprite_from_x, :sprite_from_y, :sprite_to_x, :sprite_from_y)
      }.root
      animation.resolver = resolver
      return animation
    end

    def p1_anim_3(resolver)
      animation = Yuki::Animation.instance_eval {
        move_discreet(0.2, :up_box, :up_box_from_x, :up_box_from_y, :up_box_to_x, :up_box_from_y)
      }.root
      animation.resolver = resolver
      return animation
    end

    def p1_anim_4(resolver)
      animation = Yuki::Animation.instance_eval {
        move_discreet(0.2, :down_box, :down_box_from_x, :down_box_from_y, :down_box_to_x, :down_box_from_y) |
        opacity_change(0.2, :type, :type_from_opacity, :type_to_opacity) >>
        opacity_change(0.2, :type2, :type2_from_opacity, :type2_to_opacity) >
        opacity_change(0.5, :type, 127, 255) |
        move(0.2, :sprite, :sprite_from_x, :sprite_from_y, :sprite_to_x, :sprite_from_y) |
        se_play('hall_of_fame_sound')
      }.root
      animation.resolver = resolver
      return animation
    end

    def p1_anim_5(resolver)
      sound = pkm_cry_filename
      animation = Yuki::Animation.instance_eval {
        se_play(sound) |
        move(1, :sprite2, :sprite2_from_x, :sprite2_from_y, :sprite2_to_x, :sprite2_from_y) |
        move(1.5, :type2, :type2_from_x, :type2_from_y, :type2_to_x, :type2_from_y)
      }.root
      animation.resolver = resolver
      return animation
    end

    def p1_anim_6(resolver)
      animation = Yuki::Animation.instance_eval {
        opacity_change(0.5, :type2, 127, 0) |
        move(0.5, :type2, :type2_from_x, :type2_from_y, :type2_to_x, :type2_from_y) >
        wait(1)
      }.root
      animation.resolver = resolver
      return animation
    end

    def p1_anim_7(resolver)
      animation = Yuki::Animation.instance_eval {
        opacity_change(0.5, :type, :type_from_opacity, :type_to_opacity) >
        move(0.2, :sprite, :sprite_from_x, :sprite_from_y, :sprite_to_x, :sprite_from_y) |
        move(0.25, :sprite2, :sprite2_from_x, :sprite2_from_y, :sprite2_to_x, :sprite2_from_y) >
        move_discreet(0.2, :down_box, :down_box_from_x, :down_box_from_y, :down_box_to_x, :down_box_from_y) >
        move_discreet(0.2, :up_box, :up_box_from_x, :up_box_from_y, :up_box_to_x, :up_box_from_y) >
        wait(0.3)
      }.root
      animation.resolver = resolver
      return animation
    end
  end
end
