module GamePlay
  class Hall_of_Fame
    ####################################################################################################################
    # Description of each anim of animation_phase_2                                                                    #
    # For each p2_anim_x there is a p2_resolver_anim_x, which describe every parameters for each animation method      #
    # Every parameters name you'll see in those methods is ARBITRARY and are just here to name things, they do not     #
    #   have anything to do with already existing methods.                                                             #
    ####################################################################################################################
    # p2_anim_1 : Move the first Pokemon and its info from right to middle in 1 second then wait 2 seconds             #
    #                                                                                                                  #
    # p2_anim_2_repeat : Move the center Pokemon and its info to the left, the next Pokemon and its info from right to #
    #                      middle, all of this in 1 second then wait 2 seconds                                         #
    #                                                                                                                  #
    # p2_anim_3 : Move the last Pokemon and its info from middle to left in 1 second then wait 1 second                #
    ####################################################################################################################

    private

    def animation_phase_2
      @anim_count = 0
      until @anim_count == @graveyard.size + 1
        case @anim_count
        when 0
          launch_animation(p2_anim_1(p2_resolver_anim_1.method(:fetch)))
        when @graveyard.size
          launch_animation(p2_anim_3(p2_resolver_anim_3.method(:fetch)))
        else
          launch_animation(p2_anim_2_repeat(p2_resolver_anim_2_repeat.method(:fetch)))
        end
        @anim_count += 1
      end
      @animation_state += 1
    end

    def p2_resolver_anim_1
      resolver = {
        sprite_from_x: @graveyard_stack.sprites[@anim_count].x,
        sprite_from_y: @graveyard_stack.sprites[@anim_count].y,
        sprite_to_x: @nuz_anim::SPRITE_X_MIDDLE,
        sprite: @graveyard_stack.sprites[@anim_count],
        box_from_x: @graveyard_stack.text_boxes[@anim_count].x,
        box_from_y: @graveyard_stack.text_boxes[@anim_count].y,
        box_to_x: @nuz_anim::BOX_X_MIDDLE,
        box: @graveyard_stack.text_boxes[@anim_count]
      }
      return resolver
    end

    def p2_resolver_anim_2_repeat
      resolver = p2_resolver_anim_1
      more_resolver = {
        sprite2_from_x: @graveyard_stack.sprites[@anim_count - 1].x,
        sprite2_from_y: @graveyard_stack.sprites[@anim_count - 1].y,
        sprite2_to_x: @nuz_anim::SPRITE_X_LEFT,
        sprite2: @graveyard_stack.sprites[@anim_count - 1],
        box2_from_x: @graveyard_stack.text_boxes[@anim_count - 1].x,
        box2_from_y: @graveyard_stack.text_boxes[@anim_count - 1].y,
        box2_to_x: @nuz_anim::BOX_X_LEFT,
        box2: @graveyard_stack.text_boxes[@anim_count - 1]
      }
      resolver.merge!(more_resolver)
      return resolver
    end

    def p2_resolver_anim_3
      resolver = {
        sprite_from_x: @graveyard_stack.sprites[@anim_count - 1].x,
        sprite_from_y: @graveyard_stack.sprites[@anim_count - 1].y,
        sprite_to_x: @nuz_anim::SPRITE_X_LEFT,
        sprite: @graveyard_stack.sprites[@anim_count - 1],
        box_from_x: @graveyard_stack.text_boxes[@anim_count - 1].x,
        box_from_y: @graveyard_stack.text_boxes[@anim_count - 1].y,
        box_to_x: @nuz_anim::BOX_X_LEFT,
        box: @graveyard_stack.text_boxes[@anim_count - 1]
      }
      return resolver
    end

    def p2_anim_1(resolver)
      animation = Yuki::Animation.instance_eval {
        move(1, :sprite, :sprite_from_x, :sprite_from_y, :sprite_to_x, :sprite_from_y) |
        move_discreet(1, :box, :box_from_x, :box_from_y, :box_to_x, :box_from_y) >
        wait(2)
      }.root
      animation.resolver = resolver
      return animation
    end

    def p2_anim_2_repeat(resolver)
      animation = Yuki::Animation.instance_eval {
        move(1, :sprite, :sprite_from_x, :sprite_from_y, :sprite_to_x, :sprite_from_y) |
        move_discreet(1, :box, :box_from_x, :box_from_y, :box_to_x, :box_from_y) |
        move(1, :sprite2, :sprite2_from_x, :sprite2_from_y, :sprite2_to_x, :sprite2_from_y) |
        move_discreet(1, :box2, :box2_from_x, :box2_from_y, :box2_to_x, :box2_from_y) >
        wait(2)
      }.root
      animation.resolver = resolver
      return animation
    end

    def p2_anim_3(resolver)
      animation = Yuki::Animation.instance_eval {
        move(1, :sprite, :sprite_from_x, :sprite_from_y, :sprite_to_x, :sprite_from_y) |
        move_discreet(1, :box, :box_from_x, :box_from_y, :box_to_x, :box_from_y) >
        wait(1)
      }.root
      animation.resolver = resolver
      return animation
    end
  end
end
