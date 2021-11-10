module Battle
  class Visual
    # Show HP animations
    # @param targets [Array<PFM::PokemonBattler>]
    # @param hps [Array<Integer>]
    # @param effectiveness [Array<Integer, nil>]
    # @param messages [Proc] messages shown right before the post processing
    def show_hp_animations(targets, hps, effectiveness = [], &messages)
      lock do
        animations = targets.map.with_index do |target, index|
          show_info_bar(target)
          if hps[index] && hps[index] == 0
            next Battle::Visual::FakeHPAnimation.new(@scene, target, effectiveness[index])
          elsif hps[index]
            next Battle::Visual::HPAnimation.new(@scene, target, hps[index], effectiveness[index])
          end
        end
        wait_for_animation
        scene_update_proc { animations.each(&:update) } until animations.all?(&:done?)
        messages&.call
        show_kos(targets)
      end
    end

    # Show KO animations
    # @param targets [Array<PFM::PokemonBattler>]
    def show_kos(targets)
      targets = targets.select(&:dead?)
      return if targets.empty?

      play_ko_se
      # Start all animations
      targets.each do |target|
        battler_sprite(target.bank, target.position).go_out
        hide_info_bar(target)
      end
      # Show messages
      targets.each do |target|
        @scene.display_message_and_wait(parse_text_with_pokemon(19, 0, target, PFM::Text::PKNICK[0] => target.given_name))
        target.status = 0
      end
    end

    # Show the ability animation
    # @param target [PFM::PokemonBattler]
    # @param [Boolean] no_go_out Set if the out animation should be not played automatically
    def show_ability(target, no_go_out = false)
      ability_bar = @ability_bars[target.bank][target.position]
      item_bar = @item_bars[target.bank][target.position]
      return unless ability_bar

      ability_bar.data = target
      ability_bar.go_in_ability(no_go_out)
      if !item_bar || item_bar.done?
        ability_bar.z = 0
      else
        ability_bar.z = item_bar.z + 1
      end
    end

    # Hide the ability animation (no effect if no_go_out = false)
    # @param target [PFM::PokemonBattler]
    def hide_ability(target)
      ability_bar = @ability_bars[target.bank][target.position]
      return unless ability_bar || ability_bar.no_go_out

      ability_bar.go_out
    end

    # Show the item user animation
    # @param target [PFM::PokemonBattler]
    def show_item(target)
      ability_bar = @ability_bars[target.bank][target.position]
      item_bar = @item_bars[target.bank][target.position]
      return unless item_bar

      item_bar.data = target
      item_bar.go_in_ability
      item_bar.z = ability_bar.z + 1 unless !ability_bar || ability_bar.done?
      if !ability_bar || ability_bar.done?
        item_bar.z = 0
      else
        item_bar.z = ability_bar.z + 1
      end
    end

    # Show the pokemon switch form animation
    # @param target [PFM::PokemonBattler]
    def show_switch_form_animation(target)
      battler_sprite(target.bank, target.position)&.pokemon = target
      # TODO: Implement an animation for that & write the code
    end

    # Make a move animation
    # @param user [PFM::PokemonBattler]
    # @param targets [Array<PFM::PokemonBattler>]
    # @param move [Battle::Move]
    def show_move_animation(user, targets, move)
      return unless $options.show_animation

      $data_animations ||= load_data('Data/Animations.rxdata')
      id = move.id
      user_sprite = battler_sprite(user.bank, user.position)
      target_sprite = battler_sprite(targets.first.bank, targets.first.position)
      original_rect = @viewport.rect.clone
      @viewport.rect.height = Viewport::CONFIGS[:main][:height]
      lock { @move_animator.move_animation(user_sprite, target_sprite, id, user.bank != 0) }
      @viewport.rect = original_rect
    end

    # Show a dedicated animation
    # @param target [PFM::PokemonBattler]
    # @param id [Integer]
    def show_rmxp_animation(target, id)
      return unless $options.show_animation

      wait_for_animation
      $data_animations ||= load_data('Data/Animations.rxdata')
      lock { @move_animator.animation(battler_sprite(target.bank, target.position), id, target.bank != 0) }
    end

    # Show the exp distribution
    # @param exp_data [Hash{ PFM::PokemonBattler => Integer }] info about experience each pokemon should receive
    def show_exp_distribution(exp_data)
      lock do
        exp_ui = BattleUI::ExpDistribution.new(@viewport_sub, @scene, exp_data)
        @scene.display_message_and_wait(ext_text(8999, 21))
        exp_ui.start_animation
        scene_update_proc { exp_ui.update } until exp_ui.done?
        exp_ui.dispose
      end
      exp_data.each_key { |pokemon| refresh_info_bar(pokemon) if pokemon.can_fight? }
    end

    # Show the catching animation
    # @param target_pokemon [PFM::PokemonBattler] pokemon being caught
    # @param ball [GameData::Ball] ball used
    # @param nb_bounce [Integer] number of time the ball move
    # @param caught [Integer] if the pokemon got caught
    def show_catch_animation(target_pokemon, ball, nb_bounce, caught)
      origin = battler_sprite(0, 0)
      target = battler_sprite(target_pokemon.bank, target_pokemon.position)
      sprite = UI::ThrowingBallSprite.new(origin.viewport, ball)
      animation = create_throw_ball_animation(sprite, target, origin)
      create_move_ball_animation(animation, sprite, nb_bounce)
      caught ? create_caught_animation(animation, sprite) : create_break_animation(animation, sprite, target)
      animation.start
      @animations << animation
      wait_for_animation
    end

    private

    # Create the throw ball animation
    # @param sprite [UI::ThrowingBallSprite]
    # @param target [Sprite]
    # @param origin [Sprite]
    # @return [Yuki::Animation::TimedAnimation]
    def create_throw_ball_animation(sprite, target, origin)
      ya = Yuki::Animation
      sprite.set_position(-sprite.ball_offset_y, origin.y - sprite.trainer_offset_y)
      animation = ya.scalar_offset(0.4, sprite, :y, :y=, 0, -64, distortion: :SQUARE010_DISTORTION)
      animation.parallel_play(ya.move(0.4, sprite, sprite.x, sprite.y, target.x, target.y - sprite.trainer_offset_y))
      animation.parallel_play(ya.scalar(0.4, sprite, :throw_progression=, 0, 1))
      animation.parallel_play(ya.se_play(*sending_ball_se))
      animation.play_before(ya.scalar(0.2, sprite, :open_progression=, 0, 1))
      animation.play_before(ya.scalar(0.2, target, :zoom=, sprite_zoom, 0))
      animation.play_before(ya.se_play(*opening_ball_se))
      animation.play_before(ya.scalar(0.5, sprite, :close_progression=, 0, 1))
      fall_animation = ya.scalar(1, sprite, :y=, target.y - sprite.ball_offset_y, target.y - sprite.trainer_offset_y, distortion: fall_distortion)
      sound_animation = ya.wait(0.2)
      sound_animation.play_before(ya.se_play(*bouncing_ball_se))
      sound_animation.play_before(ya.wait(0.4))
      sound_animation.play_before(ya.se_play(*bouncing_ball_se))
      sound_animation.play_before(ya.wait(0.4))
      sound_animation.play_before(ya.se_play(*bouncing_ball_se))
      animation.play_before(fall_animation)
      fall_animation.parallel_play(sound_animation)
      return animation
    end

    def fall_distortion
      return proc { |x| (Math.cos(2.5 * Math::PI * x) * Math.exp(-2 * x)).abs }
    end

    # Create the move animation
    # @param animation [Yuki::Animation::TimedAnimation]
    # @param sprite [UI::ThrowingBallSprite]
    # @param nb_bounce [Integer]
    def create_move_ball_animation(animation, sprite, nb_bounce)
      ya = Yuki::Animation
      animation.play_before(ya.wait(0.5))
      nb_bounce.clamp(0, 3).times do
        animation.play_before(ya.se_play(*moving_ball_se))
        animation.play_before(ya.scalar(0.5, sprite, :move_progression=, 0, 1))
        animation.play_before(ya.wait(0.5))
      end
    end

    # Create the move animation
    # @param animation [Yuki::Animation::TimedAnimation]
    # @param sprite [UI::ThrowingBallSprite]
    def create_caught_animation(animation, sprite)
      ya = Yuki::Animation
      animation.play_before(ya.se_play(*catching_ball_se))
      animation.play_before(ya.scalar(0.5, sprite, :caught_progression=, 0, 1))
    end

    # Create the move animation
    # @param animation [Yuki::Animation::TimedAnimation]
    # @param sprite [UI::ThrowingBallSprite]
    # @param target [Sprite]
    def create_break_animation(animation, sprite, target)
      ya = Yuki::Animation
      animation.play_before(ya.se_play(*break_ball_se))
      animation.play_before(ya.scalar(0.5, sprite, :break_progression=, 0, 1))
      animation.play_before(ya.scalar(0.2, target, :zoom=, 0, sprite_zoom))
      animation.play_before(ya.send_command_to(sprite, :dispose))
    end

    # Sprite zoom of the Pokemon battler
    def sprite_zoom
      return 1
    end

    # SE played when a Pokemon is K.O.
    def play_ko_se
      Audio.se_play('Audio/SE/Down.wav', 100, 80)
    end

    # SE played when the ball is sent
    def sending_ball_se
      return 'fall', 100, 120
    end

    # SE played when the ball is opening
    def opening_ball_se
      return 'pokeopen'
    end

    # SE played when the ball is bouncing
    def bouncing_ball_se
      return 'pokerebond'
    end

    # SE played when the ball is moving
    def moving_ball_se
      return 'pokemove'
    end

    # SE played when the Pokemon is caught
    def catching_ball_se
      return 'pokeopenbreak', 100, 180
    end

    # SE played when the Pokemon escapes from the ball
    def break_ball_se
      return 'pokeopenbreak'
    end
  end
end
