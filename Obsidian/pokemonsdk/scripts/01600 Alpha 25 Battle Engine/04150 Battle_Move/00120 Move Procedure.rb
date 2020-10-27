module Battle
  class Move
    include Hooks
    # Function starting the move procedure
    # @param user [PFM::PokemonBattler] user of the move
    # @param target_bank [Integer] bank of the target
    # @param target_position [Integer]
    def proceed(user, target_bank, target_position)
      possible_targets = battler_targets(user, logic).select { |target| target&.alive? }
      exec_hooks(Move, :possible_targets, binding)
      possible_targets.sort_by(&:spd)
      if one_target?
        right_target = possible_targets.find { |pokemon| pokemon.bank == target_bank && pokemon.position == target_position }
        right_target ||= possible_targets.find { |pokemon| pokemon.bank == target_bank && (pokemon.position - target_position).abs == 1 }
        right_target ||= possible_targets.find { |pokemon| pokemon.bank == target_bank }
        return proceed_internal(user, [right_target].compact)
      end
      # Sort target by decreasing spd
      possible_targets.reverse!
      # Choose the right bank if user could choose bank
      possible_targets.select! { |pokemon| pokemon.bank == target_bank } unless no_choice_skill?
      proceed_internal(user, possible_targets)
    end

    private

    # Internal procedure of the move
    # @param user [PFM::PokemonBattler] user of the move
    # @param targets [Array<PFM::PokemonBattler>] expected targets
    def proceed_internal(user, targets)
      usage_message(user)
      return scene.display_message(parse_text(18, 74)) if rand(100) >= accuracy

      actual_targets = accuracy_immunity_test(user, targets) # => Will call $scene.dislay_message for each accuracy fail
      play_animation(user, targets) if actual_targets.any? # TODO: check if that works properly, eg. not playing when the move does nothing
      deal_damage(user, actual_targets) && # TODO: finish
        deal_status(user, actual_targets) && # TODO: DO
        deal_stats(user, actual_targets) && # TODO: DO
        deal_effect(user, actual_targets) && # TODO: DO
        deal_terrain_effect(user, actual_targets) && # TODO: DO
        process_hooks(user, actual_targets) # TODO: rocky_helmet, iron_barbs, rough_skin
    end

    # Show the move usage message
    # @param user [PFM::PokemonBattler] user of the move
    def usage_message(user)
      PFM::Text.set_pkname(user)
      scene.display_message(parse_text_with_pokemon(8999 - GameData::Text::CSV_BASE, 12, user, PFM::Text::MOVE[0] => name))
      PFM::Text.reset_variables
    end

    # Method responsive testing accuracy and immunity.
    # It'll report the which pokemon evaded the move and which pokemon are immune to the move.
    # @param user [PFM::PokemonBattler] user of the move
    # @param targets [Array<PFM::PokemonBattler>] expected targets
    # @return [Array<PFM::PokemonBattler>]
    def accuracy_immunity_test(user, targets)
      return targets.select do |pokemon|
        if target_immune?(pokemon)
          scene.display_message(parse_text_with_pokemon(19, 210, pokemon))
          next false
        elsif rand(100) >= chance_of_hit(user, pokemon)
          scene.display_message(parse_text_with_pokemon(19, 213, pokemon))
          next false
        end

        next true
      end
    end

    # Test if the target is immune
    # @param target [PFM::PokemonBattler]
    # @return [Boolean]
    def target_immune?(target)
      # TODO: foresight / odor_sleuth effect on target (ghost type)
      # TODO: miracle eye effect on target (dark type not immue to psy)
      return calc_type_n_multiplier(target, :type1) == 0 ||
             calc_type_n_multiplier(target, :type2) == 0 ||
             calc_type_n_multiplier(target, :type3) == 0
    end

    # Play the move animation
    # @param user [PFM::PokemonBattler] user of the move
    # @param targets [Array<PFM::PokemonBattler>] expected targets
    def play_animation(user, targets)
      # TODO
    end

    # Function that deals the damage to the pokemon
    # @param user [PFM::PokemonBattler] user of the move
    # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
    def deal_damage(user, actual_targets)
      # Status move does not deal damages
      return true if status?

      rng = Random.new
      fibers = actual_targets.map do |target|
        damages = self.damages(user, target, rng) # /!\ test the substitute pokemon when substitute was used
        critical_hit = @critical
        effectiveness = @effectiveness
        log_debug("#{user} inflict #{damages} HP to #{target}")
        # TODO: Manage clone, abilities like cursed_body & sturdy, then effect, berries
        next Fiber.new do
          Fiber.yield if damages <= 0
          Fiber.yield :wait_for_animation, Visual::HPAnimation.new(scene, target, -damages, effectiveness) if damages > 0
          if critical_hit
            scene.display_message(actual_targets.size == 1 ? parse_text(18, 84) : parse_text_with_pokemon(19, 384, target))
          elsif damages > 0
            efficent_message(effectiveness, target)
          end
          handle_ko(target) if target.hp <= 0
          Fiber.yield :kill
        end
      end
      process_fiber(fibers)

      return true
    end

    # Show the effectiveness message
    # @param effectiveness [Numeric]
    # @param target [PFM::PokemonBattler]
    def efficent_message(effectiveness, target)
      if effectiveness > 1
        scene.display_message(parse_text_with_pokemon(19, 6, target))
      elsif effectiveness > 0
        scene.display_message(parse_text_with_pokemon(19, 15, target))
      end
    end

    # Function that handle the KO part
    # @param target [PFM::PokemonBattler] pokemon falling KO
    def handle_ko(target)
      sprite = scene.visual.battler_sprite(target.bank, target.position)
      scene.visual.lock do
        sprite.start_animation_KO
        scene.display_message(parse_text_with_pokemon(19, 0, target))
        while sprite.animated?
          scene.update
          Graphics.update
        end
      end
    end

    # Function that deals the status condition to the pokemon
    # @param user [PFM::PokemonBattler] user of the move
    # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
    def deal_status(user, actual_targets)
      return true # TODO
    end

    # Function that deals the stat to the pokemon
    # @param user [PFM::PokemonBattler] user of the move
    # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
    def deal_stats(user, actual_targets)
      return true # TODO
    end

    # Function that deals the effect to the pokemon
    # @param user [PFM::PokemonBattler] user of the move
    # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
    def deal_effect(user, actual_targets)
      return true # TODO
    end

    # Function that deals the terrain effect to the field
    # @param user [PFM::PokemonBattler] user of the move
    # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
    def deal_terrain_effect(user, actual_targets)
      return true # TODO
    end

    # Function that process the hooks
    # @param user [PFM::PokemonBattler] user of the move
    # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
    def process_hooks(user, actual_targets)
      exec_hooks(Move, :process_hooks, binding)
      return true
    end

    # Function that process a list of fiber
    # @param fibers [Array<Fiber>]
    def process_fiber(fibers)
      animation_stack = []
      killed_stack = []
      while fibers.any?
        # Process fiber
        fibers.each do |fiber|
          result = fiber.resume
          animation_stack << result.last if result.is_a?(Array) && result.first == :wait_for_animation
          killed_stack << fiber if result == :kill
        end
        # Kill fibers
        fibers.reject! { |fiber| killed_stack.include?(fiber) }
        killed_stack.clear
        # Play animations
        scene.visual.lock do
          while animation_stack.any?
            animation_stack.each(&:update)
            scene.update
            Graphics.update
            animation_stack.reject!(&:done?)
          end
        end
      end
    end
  end
end
