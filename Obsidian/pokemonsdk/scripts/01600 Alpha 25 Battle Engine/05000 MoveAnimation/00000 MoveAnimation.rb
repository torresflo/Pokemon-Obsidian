module Battle
  # Module responsive of handling all move animation
  #
  # All animation will have the following values in their resolver:
  #   - :visual => Battle::Visual object
  #   - :user => BattleUI::PokemonSprite of the user of the move
  #   - :target => BattleUI::PokemonSprite of the target of the move (first if user animation, current if target animation)
  #   - :viewport => Viewport of the user sprite
  module MoveAnimation
    # Variable containing the list of specific Move animations
    # This is sorted the following way : move_db_symbol => animation_reason => animation_string_data
    @specific_move_animations = {}
    # Variable containing the list of generic Move animations (fallback)
    # This variable is sorted the following way : move_kind => move_type => animation_string_data
    @generic_move_animations = {}

    module_function

    # Function that store a specific move animation
    # @param move_db_symbol [Symbol]
    # @param animation_reason [Symbol]
    # @param animation_user [Yuki::Animation::TimedAnimation] unstarted animation of user that will be serialized
    # @param animation_target [Yuki::Animation::TimedAnimation] unstarted animation of target that will be serialized
    def register_specific_animation(move_db_symbol, animation_reason, animation_user, animation_target)
      (@specific_move_animations[move_db_symbol] ||= {})[animation_reason] = Marshal.dump([animation_user, animation_target])
    end

    # Function that stores a generic move animation
    # @param move_kind [Integer] 1 = physical, 2 = special, 3 = status
    # @param move_type [Integer] type of the move
    # @param animation_user [Yuki::Animation::TimedAnimation] unstarted animation of user that will be serialized
    # @param animation_target [Yuki::Animation::TimedAnimation] unstarted animation of target that will be serialized
    def register_generic_animation(move_kind, move_type, animation_user, animation_target)
      (@generic_move_animations[move_kind] ||= {})[move_type] = Marshal.dump([animation_user, animation_target])
    end

    # Function that retreives the animation for the user & the target depending on the condition
    # @param move [Battle::Move] move used
    # @param animation_reason [Array<Symbol>] reason of the animation (in order you want it, you'll get the first that got resolved)
    # @return [Array<Yuki::Animation::TimedAnimation>, nil] animation on user, animation on target
    def get(move, *animation_reason)
      db_symbol = move.db_symbol
      found_reason = animation_reason.find { |reason| @specific_move_animations.dig(db_symbol, reason) }
      return Marshal.load(@specific_move_animations.dig(db_symbol, found_reason)) if found_reason

      generic = @generic_move_animations.dig(move.data.atk_class, move.type)
      return Marshal.load(generic) if generic

      return nil
    end

    # Function that plays an animation
    # @param animations [Array<Yuki::Animation::TimedAnimation>]
    # @param visual [Battle::Visual]
    # @param user [PFM::PokemonBattler] user of the move
    # @param targets [Array<PFM::PokemonBattler>] expected targets
    def play(animations, visual, user, targets)
      animations = animations.dup
      # @type [Yuki::Animation::TimedAnimation]
      user_animation = animations.shift
      animations << Marshal.load(Marshal.dump(animations.last)) while animations.size > targets.size
      user_sprite = visual.battler_sprite(user.bank, user.position)
      target_sprites = targets.map { |target| visual.battler_sprite(target.bank, target.position) }

      user_animation.resolver = {
        visual: visual,
        user: user_sprite,
        target: target_sprites.first,
        viewport: user_sprite.viewport
      }.method(:[])
      animations.each_with_index do |animation, index|
        animation.resolver = {
          visual: visual,
          user: user_sprite,
          target: target_sprites[index],
          viewport: user_sprite.viewport
        }.method(:[])
        animation.start
      end
      user_animation.start
      visual.animations << user_animation
      visual.animations.concat(animations)
      visual.wait_for_animation
    end
  end
end
