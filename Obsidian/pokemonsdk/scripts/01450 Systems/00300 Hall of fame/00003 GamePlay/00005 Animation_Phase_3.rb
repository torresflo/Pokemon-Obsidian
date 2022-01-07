module GamePlay
  class Hall_of_Fame
    ####################################################################################################################
    # Description of each anim of animation_phase_3                                                                    #
    # For each p3_anim_x there is a p3_resolver_anim_x, which describe every parameters for each animation method      #
    # Every parameters name you'll see in those methods is ARBITRARY and are just here to name things, they do not     #
    #   have anything to do with already existing methods.                                                             #
    ####################################################################################################################
    # p3_anim_1 : Opacity change in 0.1 second of the turning ball                                                     #
    #                                                                                                                  #
    # p3_anim_2 : Movement of trainer battler from up to middle in 0.5 second                                          #
    #             Slight movement of League Champion text box in 0.5 second                                            #
    #             Wait 0.3 second                                                                                      #
    #             Slight movement of Trainer Infos text box in 0.5 second                                              #
    #             Wait 0.5 second                                                                                      #
    #                                                                                                                  #
    # p3_anim_3 : Opacity change for every texts                                                                       #
    #                                                                                                                  #
    # p3_anim_4 : Movement for each Pokemon in a time depending on their index                                         #
    ####################################################################################################################

    private

    def animation_phase_3
      @anim_count = 0
      launch_animation(p3_anim_1(p3_resolver_anim_1))
      @parallel_update = true
      @test = true
      launch_animation(p3_anim_2(p3_resolver_anim_2))
      @test = false
      launch_animation(p3_anim_3(p3_resolver_anim_3))
      until @anim_count == $actors.size
        launch_animation(p3_anim_4(p3_resolver_anim_4))
        @anim_count += 1
      end
      @parallel_update = false
      @animation_state += 1
    end

    def p3_resolver_anim_1
      resolver = {
        ball_from_opacity: @ball.opacity,
        ball_to_opacity: 255,
        ball: @ball
      }
      resolver = resolver.method(:fetch)
      return resolver
    end

    def p3_resolver_anim_2
      resolver = {
        trainer_from_x: @party_battler.trainer_battler.x,
        trainer_from_y: @party_battler.trainer_battler.y,
        trainer_to_y: Party_Battler_Stack::Y_TRAINER,
        trainer: @party_battler.trainer_battler,
        box_from_x: @league_champ_box.x,
        box_from_y: @league_champ_box.y,
        box_to_y: @league_champ_box.y_final,
        box: @league_champ_box,
        box2_from_x: @trainer_infos_box.x,
        box2_from_y: @trainer_infos_box.y,
        box2_to_y: @trainer_infos_box.y_final,
        box2: @trainer_infos_box
      }
      resolver = resolver.method(:fetch)
      return resolver
    end

    def p3_resolver_anim_3
      resolver = {
        text_from_opacity: 0,
        text_to_opacity: 255,
        text: @league_champ_box.text,
        text2: @trainer_infos_box.name,
        text3: @trainer_infos_box.id_no,
        text4: @trainer_infos_box.play_time
      }
      resolver = resolver.method(:fetch)
      return resolver
    end

    def p3_resolver_anim_4
      resolver = {
        pokemon_from_x: @party_battler.pokemon_arr[@anim_count].x,
        pokemon_from_y: @party_battler.pokemon_arr[@anim_count].y,
        pokemon_to_x: Party_Battler_Stack::X_PARTY[@anim_count],
        pokemon_to_y: Party_Battler_Stack::Y_PARTY[@anim_count / 2],
        pokemon: @party_battler.pokemon_arr[@anim_count]
      }
      resolver = resolver.method(:fetch)
      return resolver
    end

    def p3_anim_1(resolver)
      animation = Yuki::Animation.instance_eval {
        opacity_change(0.1, :ball, :ball_from_opacity, :ball_to_opacity)
      }.root
      animation.resolver = resolver
      return animation
    end

    def p3_anim_2(resolver)
      animation = Yuki::Animation.instance_eval {
        move(0.5, :trainer, :trainer_from_x, :trainer_from_y, :trainer_from_x, :trainer_to_y) >
        move_discreet(0.5, :box, :box_from_x, :box_from_y, :box_from_x, :box_to_y) >
        wait(0.1) >
        move_discreet(0.5, :box2, :box2_from_x, :box2_from_y, :box2_from_x, :box2_to_y) >
        wait(0.5)
      }.root
      animation.resolver = resolver
      return animation
    end

    def p3_anim_3(resolver)
      animation = Yuki::Animation.instance_eval {
        opacity_change(0.1, :text, :text_from_opacity, :text_to_opacity) >
        wait(0.3) >
        opacity_change(0.1, :text2, :text_from_opacity, :text_to_opacity) >
        wait(0.3) >
        opacity_change(0.1, :text3, :text_from_opacity, :text_to_opacity) >
        wait(0.3) >
        opacity_change(0.1, :text4, :text_from_opacity, :text_to_opacity) >
        wait(0.3)
      }.root
      animation.resolver = resolver
      return animation
    end

    def p3_anim_4(resolver)
      if @anim_count <= 1
        time = 0.4
      elsif @anim_count <= 3
        time = 0.35
      else
        time = 0.3
      end
      animation = Yuki::Animation.instance_eval {
        move(time, :pokemon, :pokemon_from_x, :pokemon_from_y, :pokemon_to_x, :pokemon_to_y) >
        wait(0.5)
      }.root
      animation.resolver = resolver
      return animation
    end
  end
end
